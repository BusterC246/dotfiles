#!/usr/bin/env python3
"""pdf_read — accurate PDF -> Markdown for AI agents, powered by pdf-inspector.

Why: many AI models cannot read PDFs directly, and naive converters mangle
layout (columns, tables, headings), confusing the model. pdf-inspector is a
fast Rust engine that classifies the PDF (text vs scanned), extracts text with
reading-order awareness, and converts it to clean Markdown — no OCR needed for
the ~54% of PDFs that are text-based.

This wrapper is the agent-facing CLI: it runs on macOS / Linux / Windows with
CPython >= 3.8 and only requires `pip install pdf-inspector` (prebuilt wheels,
no Rust toolchain).

Output contract (for AI agents):
  - Markdown is written to <input>.md by default (or --out FILE).
  - Page markers `<!-- Page N -->` are inserted so the model can cite pages.
  - Pages without embedded text are flagged `<!-- OCR REQUIRED: page N -->`;
    a scanned/image PDF exits 0 with warnings unless --fail-on-ocr is given,
    so pipelines can route those pages to an OCR engine (see --ocr-cmd).
  - `--json` emits a machine-readable envelope; with --stdout the envelope
    goes to stderr so stdout stays pure Markdown.
  - `--chunks N` additionally writes context-sized chunk files + a manifest,
    for models with small context windows.

Usage:
  pdf_read.py document.pdf                     # write document.md
  pdf_read.py document.pdf --classify          # type/confidence/OCR pages only
  pdf_read.py document.pdf --pages 1,3,5-10    # select pages (1-indexed)
  pdf_read.py document.pdf --chunks 8000       # also emit <=8000-token chunks
  pdf_read.py document.pdf --json --stdout     # markdown on stdout, JSON on stderr
  pdf_read.py document.pdf --ocr-cmd 'tesseract {input} stdout -l eng'
  pdf_read.py document.pdf --fail-on-ocr       # exit 3 if any page needs OCR

Exit codes: 0 success (OCR-needing pages are reported, not fatal)
            1 error (missing file, unreadable PDF, dependency missing)
            2 usage error
            3 --fail-on-ocr: pages still lack reliable text after the OCR hook
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import signal
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import pdf_inspector
except ImportError as exc:  # pragma: no cover - exercised on fresh machines
    sys.stderr.write(
        "ERROR: the 'pdf_inspector' Python package is not installed.\n"
        "Install it with:\n"
        "    pip install pdf-inspector\n"
        "Prebuilt wheels cover CPython >= 3.8 on macOS (Intel + Apple "
        "Silicon), Linux (x86_64, aarch64), and Windows (x64) — no Rust "
        "toolchain needed. On this machine:\n"
        "    python3 -m pip install pdf-inspector\n"
        f"Import failed: {exc}\n"
    )
    sys.exit(1)

VERSION = "0.1.0"

# Rough token estimate: CJK chars ~1 token each, everything else ~4 chars/token.
_CJK_RE = re.compile(
    "[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\uff66-\uff9f"
    "\uac00-\ud7af]"
)

OCR_NEEDED_MARKER = "<!-- OCR REQUIRED: page {page} has no reliable embedded text -->"
OCR_RESULT_MARKER = "<!-- OCR page {page}: {source} -->"


def estimate_tokens(text: str) -> int:
    """Heuristic token count (good enough for chunk sizing)."""
    if not text:
        return 0
    cjk = len(_CJK_RE.findall(text))
    other = len(text) - cjk
    return max(1, cjk + other // 4)


# Upper bound on pages accepted in a --pages selection, protecting against a
# crafted PDF that claims billions of pages (range expansion would OOM).
MAX_SELECTED_PAGES = 100_000


def parse_pages(spec: str, page_count: int) -> list[int]:
    """Parse '1,3,5-10' (1-indexed) into a 0-indexed page list."""
    pages: list[int] = []
    for part in spec.split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            start_s, end_s = part.split("-", 1)
            start, end = int(start_s), int(end_s)
            if start > end:
                raise ValueError(f"range {part} is reversed")
        else:
            start = end = int(part)
        if end - start + 1 > MAX_SELECTED_PAGES:
            raise ValueError(
                f"range {part} exceeds the {MAX_SELECTED_PAGES}-page cap"
            )
        if len(pages) + (end - start + 1) > MAX_SELECTED_PAGES:
            raise ValueError(
                f"selection exceeds the {MAX_SELECTED_PAGES}-page cap"
            )
        for p in range(start, end + 1):
            if p < 1 or p > page_count:
                raise ValueError(
                    f"page {p} out of range (document has {page_count} pages)"
                )
            pages.append(p - 1)
    if not pages:
        raise ValueError("empty page selection")
    return pages


def build_markdown(pages_result, page_markers: bool = True) -> str:
    """Join per-page Markdown with `<!-- Page N -->` markers and OCR flags."""
    out: list[str] = []
    for p in pages_result.pages:
        label = f"<!-- Page {p.page + 1} -->"
        if p.needs_ocr:
            if page_markers:
                out.append(label)
            out.append(OCR_NEEDED_MARKER.format(page=p.page + 1))
            continue
        if not p.markdown:
            continue
        if page_markers:
            out.append(label)
        out.append(p.markdown)
    return "\n\n".join(out).strip() + "\n"


def _slice_line(line: str, max_tokens: int) -> list[str]:
    """Slice a pathologically long line into <= max_tokens-token pieces."""
    pieces: list[str] = []
    cur: list[str] = []
    cur_tokens = 0.0
    for ch in line:
        cost = 1.0 if _CJK_RE.match(ch) else 0.25
        if cur and cur_tokens + cost > max_tokens:
            pieces.append("".join(cur))
            cur, cur_tokens = [], 0.0
        cur.append(ch)
        cur_tokens += cost
    if cur:
        pieces.append("".join(cur))
    return pieces


def _fractional_tokens(text: str) -> float:
    """Exact-cost accounting (no per-piece flooring) for chunk budgeting."""
    if not text:
        return 0.0
    cjk = len(_CJK_RE.findall(text))
    return cjk + (len(text) - cjk) * 0.25


# Reserve for the `<!-- Chunk pages: ... -->` header + separators so that
# estimate_tokens(chunk) is guaranteed <= max_tokens.
HEAD_RESERVE_TOKENS = 10


def split_chunks(blocks: list[tuple[int, str]], max_tokens: int) -> list[str]:
    """Greedy chunking preferring page and paragraph boundaries.

    Guarantees estimate_tokens(chunk) <= max_tokens for every chunk.
    blocks: (1-indexed page number, markdown text) tuples.
    """
    budget = max(max_tokens - HEAD_RESERVE_TOKENS, 1)
    chunks: list[str] = []
    cur_blocks: list[tuple[int, str]] = []
    cur_cost = 0.0

    def flush() -> None:
        nonlocal cur_blocks, cur_cost
        if not cur_blocks:
            return
        pages = sorted({p for p, _ in cur_blocks})
        if len(pages) == 1:
            head = f"<!-- Chunk pages: {pages[0]} -->"
        else:
            head = f"<!-- Chunk pages: {pages[0]}-{pages[-1]} -->"
        body = "\n\n".join(t for _, t in cur_blocks)
        chunks.append(f"{head}\n\n{body}")
        cur_blocks, cur_cost = [], 0.0

    for page, text in blocks:
        paragraphs = re.split(r"\n\s*\n", text)
        for para in paragraphs:
            if not para.strip():
                continue
            cost = _fractional_tokens(para)
            if cur_blocks and cur_cost + cost > budget:
                flush()
            if cost > budget:
                # Oversized paragraph: hard-split on lines.
                lines = para.splitlines()
                piece: list[str] = []
                piece_cost = 0.0
                for line in lines:
                    line_cost = _fractional_tokens(line) + (0.25 if piece else 0.0)
                    if line_cost > budget:
                        if piece:
                            cur_blocks.append((page, "\n".join(piece)))
                            flush()
                            piece, piece_cost = [], 0.0
                        for sliced in _slice_line(line, budget):
                            cur_blocks.append((page, sliced))
                            flush()
                        continue
                    if piece and piece_cost + line_cost > budget:
                        cur_blocks.append((page, "\n".join(piece)))
                        flush()
                        piece, piece_cost = [], 0.0
                    piece.append(line)
                    piece_cost += line_cost
                if piece:
                    cur_blocks.append((page, "\n".join(piece)))
                    flush()
            else:
                if cur_blocks:
                    cur_cost += 0.5  # the "\n\n" separator joining blocks
                cur_blocks.append((page, para))
                cur_cost += cost
    flush()
    return chunks


def _shell_quote(value: str) -> str:
    """Quote a value for the agent-supplied OCR shell template.

    POSIX: shlex.quote (single quotes). Windows cmd.exe: double quotes with
    inner quotes doubled. Placeholders must be used BARE in the template
    (e.g. `tesseract {input} stdout`) — never wrapped in quotes by hand,
    because pdf_read quotes them (hand-quoting would double-quote).
    """
    if os.name == "nt":
        # cmd.exe expands %VAR% even inside double quotes and treats `!` in
        # delayed expansion; values containing them cannot be safely quoted.
        # Reject rather than execute a mutated command.
        if "%" in value or "!" in value:
            raise ValueError(
                "value contains '%' or '!' which cmd.exe cannot quote safely"
            )
        return '"' + value.replace('"', '""') + '"'
    return shlex.quote(value)


# Upper bound for OCR output captured per page (protects memory on hostile
# inputs); a single page of OCR text is normally < 1 MB.
MAX_OCR_OUTPUT_BYTES = 64 * 1024 * 1024

# Terminal-control characters stripped from echoed diagnostics and output
# (hostile filenames, OCR output, or PDF text must not be able to tamper
# with agent terminals). C0 controls + DEL + C1 (incl. 8-bit CSI \x9b) +
# Unicode line/paragraph separators; tabs/newlines are preserved.
_CONTROL_RE = re.compile(
    r"[\x00-\x08\x0b\x0c\x0e-\x1f\x7f\x80-\x9f\u2028\u2029]"
)


def _sanitize(text: str) -> str:
    """Replace terminal-control characters with '?' in echoed text."""
    return _CONTROL_RE.sub("?", text)


# In --json mode, warnings are buffered here and merged into the envelope's
# "warnings" list so stderr stays pure JSON for agents.
_WARN_SINK: list[str] | None = None


def _warn(msg: str) -> None:
    """Emit a warning to stderr, or buffer it for the JSON envelope."""
    if _WARN_SINK is not None:
        _WARN_SINK.append(msg)
    else:
        sys.stderr.write(msg)


def _kill_process_tree(proc: "subprocess.Popen") -> None:
    """Kill the shell and its whole process group (grandchildren included)."""
    if os.name == "nt":
        subprocess.run(
            ["taskkill", "/PID", str(proc.pid), "/T", "/F"],
            capture_output=True,
        )
        return
    try:
        os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
    except (ProcessLookupError, PermissionError):
        try:
            proc.kill()
        except OSError:
            pass


def _read_capped(path: Path) -> str:
    """Read a file capped at MAX_OCR_OUTPUT_BYTES, decoding lossily."""
    if not path.exists():
        return ""
    if path.stat().st_size > MAX_OCR_OUTPUT_BYTES:
        _warn(
            f"WARNING: OCR output exceeds {MAX_OCR_OUTPUT_BYTES} bytes; "
            "truncated\n"
        )
    with open(path, "rb") as fh:
        return fh.read(MAX_OCR_OUTPUT_BYTES).decode("utf-8", errors="replace")


def _stem(path: Path) -> Path:
    """Suffix-stripping that never raises (pathlib with_suffix('') can)."""
    if path.suffix:
        return Path(str(path)[: -len(path.suffix)])
    return path


# Single-pass placeholder substitution: substituted values are never
# rescanned, so a filename containing "{out}" cannot corrupt the template.
_PLACEHOLDER_RE = re.compile(r"\{(\w+)\}")


def run_ocr_cmd(template: str, pdf_path: Path, page: int, stem: Path) -> str:
    """Run the agent-provided OCR command for one page.

    Contract: the command writes the page's text to stdout, or to the file
    given as {out}. Returns the extracted text (possibly empty).
    Placeholders are shell-quoted automatically — use them bare.
    Child stdout/stderr stream to capped files, so hostile OCR output cannot
    exhaust memory; a 600s timeout bounds runtime.
    """
    try:
        with tempfile.TemporaryDirectory(prefix="pdf_read_ocr_") as tmp:
            out_file = Path(tmp) / f"page-{page}.txt"
            stdout_path = Path(tmp) / f"page-{page}.stdout"
            stderr_path = Path(tmp) / f"page-{page}.stderr"
            try:
                values = {
                    "input": _shell_quote(str(pdf_path.resolve())),
                    "page": _shell_quote(str(page)),
                    "stem": _shell_quote(str(stem)),
                    "outdir": _shell_quote(str(Path(tmp))),
                    "out": _shell_quote(str(out_file)),
                }
                quoted = _PLACEHOLDER_RE.sub(
                    lambda m: values.get(m.group(1), m.group(0)), template
                )
            except ValueError as exc:
                _warn(f"WARNING: OCR command skipped on page {page}: {exc}\n")
                return ""
            with open(stdout_path, "wb") as so, open(stderr_path, "wb") as se:
                proc = subprocess.Popen(
                    quoted,
                    shell=True,
                    stdout=so,
                    stderr=se,
                    stdin=subprocess.DEVNULL,
                    start_new_session=os.name != "nt",
                )
                try:
                    proc.wait(timeout=600)
                except subprocess.TimeoutExpired:
                    _kill_process_tree(proc)
                    try:
                        proc.wait()
                    except OSError:
                        pass
                    _warn(f"WARNING: OCR command timed out on page {page}\n")
                    return ""
            if proc.returncode != 0:
                _warn(
                    f"WARNING: OCR command failed on page {page} "
                    f"(exit {proc.returncode}): "
                    f"{_sanitize(_read_capped(stderr_path).strip())}\n"
                )
                return ""
            if out_file.exists():
                return _read_capped(out_file)
            return _read_capped(stdout_path)
    except OSError as exc:
        _warn(
            f"WARNING: OCR page {page} failed (temp dir/IO): "
            f"{_sanitize(str(exc))}\n"
        )
        return ""


def install_hint(exc: BaseException) -> str:
    return (
        "The PDF could not be processed by pdf-inspector "
        f"({exc.__class__.__name__}: {_sanitize(str(exc))}). If the file is "
        "password-protected or malformed, pdf-inspector cannot read it; if it "
        "is a scanned document, extract the pages flagged for OCR instead."
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="pdf_read.py",
        description=(
            "Accurate PDF -> Markdown for AI agents via pdf-inspector. "
            "Writes <input>.md plus <input>.md.meta.json by default."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "OCR fallback: scanned/image PDFs have no embedded text. "
            "Use --ocr-cmd with a template like "
            'tesseract {input} stdout -l eng (text on stdout) or a command '
            'that writes text to {out}. Placeholders are shell-quoted '
            "automatically — use them bare, do not wrap them in quotes. "
            "See README.md for examples."
        ),
    )
    parser.add_argument("pdf", help="path to the PDF file")
    parser.add_argument(
        "--out",
        metavar="FILE",
        help="output Markdown path (default: <input>.md)",
    )
    parser.add_argument(
        "--pages",
        metavar="SPEC",
        help="pages to extract, 1-indexed, e.g. 1,3,5-10 (default: all)",
    )
    parser.add_argument(
        "--classify",
        "--detect-only",
        action="store_true",
        help="classify only: PDF type, confidence, OCR pages; no extraction",
    )
    parser.add_argument(
        "--json", action="store_true", help="machine-readable envelope on stdout"
    )
    parser.add_argument(
        "--stdout",
        action="store_true",
        help="print Markdown to stdout instead of writing a file "
        "(with --json the envelope goes to stderr)",
    )
    parser.add_argument(
        "--chunks",
        type=int,
        metavar="MAX_TOKENS",
        help="also write context-sized chunks (<= MAX_TOKENS tokens each) "
        "plus a <stem>.chunks.json manifest",
    )
    parser.add_argument(
        "--ocr-cmd",
        metavar="TEMPLATE",
        help='run this shell command for every page needing OCR. '
        'Placeholders: {input} {page} {stem} {outdir} {out} '
        '(text must go to stdout or to the {out} file; placeholders are '
        "shell-quoted automatically — use them bare)",
    )
    parser.add_argument(
        "--fail-on-ocr",
        action="store_true",
        help="exit 3 when any page has no embedded text (for OCR routing)",
    )
    parser.add_argument(
        "--no-page-markers",
        action="store_true",
        help="omit `<!-- Page N -->` markers from the Markdown",
    )
    parser.add_argument(
        "--version", action="version", version=f"pdf_read {VERSION}"
    )
    args = parser.parse_args(argv)
    global _WARN_SINK
    _WARN_SINK = [] if args.json else None
    if args.chunks is not None and args.chunks < 1:
        parser.error("--chunks must be a positive number of tokens")
    if args.chunks is not None and args.chunks < 64:
        parser.error(
            "--chunks must be at least 64 tokens (chunk headers are ~10 "
            "tokens; smaller budgets cannot be honored)"
        )
    if args.ocr_cmd is not None and not args.ocr_cmd.split():
        parser.error("--ocr-cmd must contain a command")

    pdf = Path(args.pdf)
    if not pdf.is_file():
        sys.stderr.write(f"ERROR: file not found: {_sanitize(str(pdf))}\n")
        return 1

    try:
        classification = pdf_inspector.classify_pdf(str(pdf))
    except Exception as exc:  # encrypted, malformed, ...
        sys.stderr.write(f"ERROR: {install_hint(exc)}\n")
        return 1

    pdf_type = classification.pdf_type
    page_count = classification.page_count
    ocr_pages_1 = sorted({p + 1 for p in classification.pages_needing_ocr})
    confidence = classification.confidence

    summary = (
        f"pdf_read: {_sanitize(pdf.name)} — type={pdf_type} "
        f"confidence={confidence:.2f} pages={page_count}"
        + (f" pages_needing_ocr={ocr_pages_1}" if ocr_pages_1 else "")
    )

    if args.classify:
        if args.json:
            json.dump(
                {
                    "source": str(pdf),
                    "pdf_type": pdf_type,
                    "confidence": confidence,
                    "page_count": page_count,
                    "pages_needing_ocr": ocr_pages_1,
                },
                sys.stdout,
            )
            sys.stdout.write("\n")
        else:
            sys.stdout.write(summary + "\n")
        if args.fail_on_ocr and ocr_pages_1:
            sys.stderr.write(
                f"ERROR: {len(ocr_pages_1)} page(s) need OCR "
                f"({ocr_pages_1}); rerouting to OCR (--fail-on-ocr)\n"
            )
            return 3
        return 0

    # ---- extraction -------------------------------------------------------
    pages_0: list[int] | None = None
    if args.pages is not None:
        try:
            pages_0 = parse_pages(args.pages, page_count)
        except ValueError as exc:
            sys.stderr.write(f"ERROR: --pages: {_sanitize(str(exc))}\n")
            return 2

    try:
        result = pdf_inspector.extract_pages_markdown(str(pdf), pages_0)
    except Exception as exc:
        sys.stderr.write(f"ERROR: {install_hint(exc)}\n")
        return 1

    markdown = build_markdown(result, page_markers=not args.no_page_markers)
    # Output boundary: strip terminal-control chars from engine-extracted
    # text too (a malicious PDF could otherwise smuggle escape sequences
    # into stdout or the .md file). OCR-spliced text is sanitized separately.
    markdown = _sanitize(markdown)

    # OCR routing scope: only pages actually in the extraction selection count
    # for the OCR hook and --fail-on-ocr (classify() reports the whole doc).
    selected_1: set[int] | None = (
        {p + 1 for p in pages_0} if pages_0 is not None else None
    )
    ocr_scope = sorted(
        set(result.pages_needing_ocr)
        | {p for p in ocr_pages_1 if p <= page_count}
    )
    if selected_1 is not None:
        ocr_scope = [p for p in ocr_scope if p in selected_1]
    if len(ocr_scope) > MAX_SELECTED_PAGES:
        _warn(
            f"WARNING: {len(ocr_scope)} pages need OCR; processing only the "
            f"first {MAX_SELECTED_PAGES} (increase the cap to process more)\n"
        )
        ocr_scope = ocr_scope[:MAX_SELECTED_PAGES]

    # OCR fallback hook: splice per-page OCR text into the markers.
    ocr_outputs: dict[int, str] = {}
    if args.ocr_cmd and ocr_scope:
        for page in ocr_scope:
            text = run_ocr_cmd(args.ocr_cmd, pdf, page, _stem(pdf))
            if text.strip():
                clean_text = _sanitize(text.strip())
                source = _sanitize(os.path.basename(args.ocr_cmd.split()[0]))
                block = OCR_RESULT_MARKER.format(page=page, source=source)
                markdown = markdown.replace(
                    OCR_NEEDED_MARKER.format(page=page),
                    f"{block}\n\n{clean_text}",
                )
                ocr_outputs[page] = clean_text
            else:
                _warn(
                    f"WARNING: no OCR text recovered for page {page}; "
                    "keeping the OCR-required marker\n"
                )

    meta = {
        "tool": "pdf_read",
        "version": VERSION,
        "engine": "pdf-inspector",
        "source": str(pdf),
        "pdf_type": pdf_type,
        "confidence": confidence,
        "page_count": page_count,
        "pages_needing_ocr": ocr_pages_1,
        "pages_with_tables": getattr(result, "pages_with_tables", []),
        "pages_with_columns": getattr(result, "pages_with_columns", []),
        "is_complex_layout": getattr(result, "is_complex", False),
        "ocr_pages": sorted(ocr_outputs),
        "warnings": [],
    }
    if pdf_type != "text_based":
        meta["warnings"].append(
            f"PDF classified as '{pdf_type}'; pages {ocr_pages_1} have no "
            "embedded text and were flagged (see --ocr-cmd)."
        )
    if ocr_scope and not args.ocr_cmd:
        meta["warnings"].append(
            f"Pages {ocr_scope} need OCR — provide --ocr-cmd to fill them in."
        )
    if hasattr(result, "needs_ocr") and getattr(result, "needs_ocr", False):
        meta["warnings"].append("extract_pages_markdown reports unreliable text.")

    # Buffer --json-mode warnings into the envelope exactly once, at each
    # output point (meta file and stdout/stderr envelope).
    sink_merged = False

    def merge_sink() -> None:
        nonlocal sink_merged
        if _WARN_SINK and not sink_merged:
            meta["warnings"].extend(_WARN_SINK)
            sink_merged = True

    # Exit 3 only for pages that STILL lack reliable text after --ocr-cmd.
    # Checked before any output (files or stdout) so a rerouted run never
    # produces partial markdown, chunks, or an envelope.
    if args.fail_on_ocr and ocr_scope:
        unresolved = [p for p in ocr_scope if p not in ocr_outputs]
        if unresolved:
            sys.stderr.write(
                f"ERROR: {len(unresolved)} page(s) still need OCR "
                f"({unresolved}); rerouting to OCR (--fail-on-ocr)\n"
            )
            return 3

    out_path: str | None = None
    chunks_manifest: list[dict] = []
    if not args.stdout:
        out_path = args.out or str(_stem(pdf)) + ".md"
        try:
            Path(out_path).write_text(markdown, encoding="utf-8")
            meta["output"] = out_path
            merge_sink()
            Path(out_path + ".meta.json").write_text(
                json.dumps(meta, indent=2), encoding="utf-8"
            )
            if args.chunks and args.chunks > 0:
                # Build chunks from the FINAL markdown (page markers), so
                # chunk files match the .md exactly — including OCR-spliced
                # text and sanitization.
                page_blocks: list[tuple[int, str]] = []
                current_page: int | None = None
                current_lines: list[str] = []
                for line in markdown.splitlines(keepends=True):
                    match = re.match(r"<!-- Page (\d+) -->", line.strip())
                    if match:
                        if current_page is not None:
                            page_blocks.append(
                                (current_page, "".join(current_lines).strip())
                            )
                        current_page = int(match.group(1))
                        current_lines = []
                    else:
                        current_lines.append(line)
                if current_page is not None:
                    page_blocks.append(
                        (current_page, "".join(current_lines).strip())
                    )
                if not page_blocks:
                    # --no-page-markers (or a PDF with no markers): fall back
                    # to per-page engine output so --chunks still works.
                    page_blocks = [
                        (p.page + 1, _sanitize(p.markdown))
                        for p in result.pages
                        if not p.needs_ocr and p.markdown
                    ]
                chunks = split_chunks(
                    [b for b in page_blocks if b[1]], args.chunks
                )
                stem = _stem(Path(out_path))
                for i, chunk in enumerate(chunks, 1):
                    chunk_path = stem.with_name(f"{stem.name}.chunk-{i:03d}.md")
                    chunk_path.write_text(chunk, encoding="utf-8")
                    chunks_manifest.append(
                        {
                            "file": str(chunk_path),
                            "approx_tokens": estimate_tokens(chunk),
                            "chunk": i,
                        }
                    )
                manifest_path = Path(str(out_path) + ".chunks.json")
                manifest_path.write_text(
                    json.dumps(chunks_manifest, indent=2), encoding="utf-8"
                )
                meta["chunks"] = chunks_manifest
                meta["chunks_manifest"] = str(manifest_path)
        except OSError as exc:
            sys.stderr.write(f"ERROR: cannot write output: {_sanitize(str(exc))}\n")
            return 1

    if args.stdout and args.chunks:
        _warn(
            "WARNING: --chunks writes files and is ignored with --stdout; "
            "use file mode for chunking\n"
        )
    if args.stdout and args.out:
        _warn(
            "WARNING: --out is ignored with --stdout (markdown goes to "
            "stdout)\n"
        )

    # ---- output -----------------------------------------------------------
    merge_sink()
    if args.json:
        stream = sys.stderr if args.stdout else sys.stdout
        if args.stdout:
            meta["markdown"] = markdown
        json.dump(meta, stream)
        stream.write("\n")
    if args.stdout:
        sys.stdout.write(markdown)
        if not markdown.endswith("\n"):
            sys.stdout.write("\n")
    else:
        sys.stderr.write(summary + "\n")
        sys.stderr.write(f"wrote {_sanitize(str(out_path))} ({len(markdown)} chars)\n")
        if args.chunks:
            sys.stderr.write(
                f"wrote {len(chunks_manifest)} chunks "
                f"(manifest: {_sanitize(str(meta.get('chunks_manifest')))})"
                "\n"
            )
    return 0


if __name__ == "__main__":
    sys.exit(main())
