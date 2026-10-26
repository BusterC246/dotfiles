#!/usr/bin/env python3
"""End-to-end tests for pdf_read.py (runs with: python -m unittest discover -s tests).

Covers: text-PDF conversion accuracy, page markers, page selection, chunking,
JSON contract, scanned/mixed OCR routing, OCR fallback hook, and error paths.
"""
from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

SKILL_DIR = Path(__file__).resolve().parent.parent
PDF_READ = SKILL_DIR / "scripts" / "pdf_read.py"
FIXTURES = Path(__file__).resolve().parent / "fixtures"
ATTENTION = FIXTURES / "attention.pdf"          # text_based, 15 pages, tables
SCANNED = FIXTURES / "scanned_sample.pdf"       # scanned, 2 pages, all need OCR
MIXED = FIXTURES / "mixed_sample.pdf"           # mixed, page 1 needs OCR
ONE_PAGE = FIXTURES / "government_positions_women.pdf"  # text_based, 1 page

POSIX = os.name == "posix"

# Downloaded corpus fixtures are not committed (large); tests skip when missing.
HAS_ATTENTION = ATTENTION.exists()
HAS_ONE_PAGE = ONE_PAGE.exists()
NEED_DOWNLOADED = (
    "fixture not present — re-download from "
    "github.com/firecrawl/pdf-inspector/tree/main/tests/fixtures"
)


def run_pdf_read(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(PDF_READ), *args],
        capture_output=True,
        text=True,
        timeout=300,
    )


def load_module() -> "module":
    spec = importlib.util.spec_from_file_location("pdf_read", PDF_READ)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


class TestUnit(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mod = load_module()

    def test_estimate_tokens(self):
        est = self.mod.estimate_tokens
        self.assertGreater(est("hello world"), 0)
        self.assertLess(est("hello world"), est("hello world hello world hello world"))
        self.assertGreater(est("日本語テキスト"), est("abcd"))

    def test_sanitize_strips_control_chars(self):
        sanitize = self.mod._sanitize
        self.assertEqual(sanitize("evil\x1b]0;pwned\x07.pdf"), "evil?]0;pwned?.pdf")
        self.assertEqual(sanitize("plain name.pdf"), "plain name.pdf")
        self.assertNotIn("\x1b", sanitize("\x1b[2J"))
        self.assertEqual(sanitize("a\x9bb"), "a?b")       # C1 CSI
        self.assertNotIn("\u2028", sanitize("x\u2028y"))  # line separator
        self.assertEqual(sanitize("keep\ttab\nand\rnewline"), "keep\ttab\nand\rnewline")

    def test_read_capped_bounds_output(self):
        cap = self.mod.MAX_OCR_OUTPUT_BYTES
        with tempfile.TemporaryDirectory() as tmp:
            big = Path(tmp) / "big.txt"
            big.write_bytes(b"x" * (cap + 1024))
            got = self.mod._read_capped(big)
            self.assertEqual(len(got), cap)

    def test_parse_pages(self):
        parse = self.mod.parse_pages
        self.assertEqual(parse("1,3,5-7", 10), [0, 2, 4, 5, 6])
        self.assertEqual(parse("10", 10), [9])
        with self.assertRaises(ValueError):
            parse("11", 10)   # out of range
        with self.assertRaises(ValueError):
            parse("7-3", 10)  # reversed range
        with self.assertRaises(ValueError):
            parse("", 10)     # empty
        with self.assertRaises(ValueError):
            parse("1-2000000", 2000000)  # expansion cap (anti-OOM)
        with self.assertRaises(ValueError):
            # many small ranges summing beyond the cap
            parse(",".join(f"{i}-{i + 999}" for i in range(1, 200001)), 300000)


class TestTextPdf(unittest.TestCase):
    @unittest.skipUnless(HAS_ATTENTION, NEED_DOWNLOADED)
    def test_convert_selected_pages(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "out.md"
            proc = run_pdf_read(str(ATTENTION), "--pages", "1-2", "--out", str(out))
            self.assertEqual(proc.returncode, 0, proc.stderr)
            md = out.read_text(encoding="utf-8")
            self.assertIn("Attention Is All You Need", md)
            self.assertIn("Transformer", md)
            self.assertIn("<!-- Page 1 -->", md)
            self.assertIn("<!-- Page 2 -->", md)
            self.assertNotIn("<!-- Page 3 -->", md)

    @unittest.skipUnless(HAS_ATTENTION, NEED_DOWNLOADED)
    def test_full_document_accuracy(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "full.md"
            proc = run_pdf_read(str(ATTENTION), "--out", str(out))
            self.assertEqual(proc.returncode, 0, proc.stderr)
            md = out.read_text(encoding="utf-8")
            for phrase in (
                "Attention Is All You Need",
                "self-attention",
                "Multi-Head Attention",
                "positional encodings",
                "BLEU",
            ):
                self.assertIn(phrase, md, f"missing expected phrase: {phrase!r}")
            # structural markers
            self.assertIn("# 1 Introduction", md)
            self.assertIn("|", md)  # at least one Markdown table converted
            for page in range(1, 16):
                self.assertIn(f"<!-- Page {page} -->", md)
            # metadata envelope
            meta = json.loads((Path(str(out) + ".meta.json")).read_text(encoding="utf-8"))
            self.assertEqual(meta["pdf_type"], "text_based")
            self.assertEqual(meta["page_count"], 15)
            self.assertEqual(meta["pages_needing_ocr"], [])

    @unittest.skipUnless(HAS_ATTENTION, NEED_DOWNLOADED)
    def test_page_selection_out_of_range(self):
        proc = run_pdf_read(str(ATTENTION), "--pages", "99")
        self.assertEqual(proc.returncode, 2)
        self.assertIn("out of range", proc.stderr)

    def test_missing_file(self):
        proc = run_pdf_read(str(FIXTURES / "nope.pdf"))
        self.assertEqual(proc.returncode, 1)

    @unittest.skipUnless(HAS_ATTENTION, NEED_DOWNLOADED)
    def test_classify_only(self):
        proc = run_pdf_read(str(ATTENTION), "--classify")
        self.assertEqual(proc.returncode, 0)
        self.assertIn("text_based", proc.stdout)


class TestChunks(unittest.TestCase):
    @unittest.skipUnless(HAS_ATTENTION, NEED_DOWNLOADED)
    def test_chunking_writes_manifest(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "doc.md"
            proc = run_pdf_read(str(ATTENTION), "--out", str(out), "--chunks", "2000")
            self.assertEqual(proc.returncode, 0, proc.stderr)
            manifest_path = Path(str(out) + ".chunks.json")
            self.assertTrue(manifest_path.exists())
            chunks = json.loads(manifest_path.read_text(encoding="utf-8"))
            self.assertGreaterEqual(len(chunks), 4)
            for entry in chunks:
                self.assertLessEqual(entry["approx_tokens"], 2000)
                chunk_file = Path(entry["file"])
                self.assertTrue(chunk_file.exists())
                self.assertGreater(chunk_file.stat().st_size, 0)

    @unittest.skipUnless(HAS_ONE_PAGE, NEED_DOWNLOADED)
    def test_chunks_ignored_with_stdout(self):
        proc = run_pdf_read(str(ONE_PAGE), "--stdout", "--chunks", "1000")
        self.assertEqual(proc.returncode, 0)
        self.assertIn("ignored with --stdout", proc.stderr)


class TestScannedRouting(unittest.TestCase):
    def test_classify_scanned(self):
        proc = run_pdf_read(str(SCANNED), "--classify", "--json")
        self.assertEqual(proc.returncode, 0)
        meta = json.loads(proc.stdout)
        self.assertEqual(meta["pdf_type"], "scanned")
        self.assertEqual(meta["pages_needing_ocr"], [1, 2])

    def test_convert_flags_ocr_pages_but_succeeds(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "s.md"
            proc = run_pdf_read(str(SCANNED), "--out", str(out))
            self.assertEqual(proc.returncode, 0, proc.stderr)
            md = out.read_text(encoding="utf-8")
            self.assertIn(
                "<!-- OCR REQUIRED: page 1 has no reliable embedded text -->", md
            )
            self.assertIn(
                "<!-- OCR REQUIRED: page 2 has no reliable embedded text -->", md
            )
            meta = json.loads(Path(str(out) + ".meta.json").read_text(encoding="utf-8"))
            self.assertEqual(meta["pdf_type"], "scanned")
            self.assertTrue(meta["warnings"])

    def test_fail_on_ocr_exit_code(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "s.md"
            proc = run_pdf_read(str(SCANNED), "--fail-on-ocr", "--out", str(out))
            self.assertEqual(proc.returncode, 3)

    @unittest.skipUnless(POSIX, "OCR hook uses a POSIX shell command")
    def test_ocr_fallback_hook(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "s.md"
            proc = run_pdf_read(
                str(SCANNED),
                "--out",
                str(out),
                "--ocr-cmd",
                'printf "OCR-TEXT page {page}" > {out}',
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
            md = out.read_text(encoding="utf-8")
            self.assertIn("<!-- OCR page 1:", md)
            self.assertIn("OCR-TEXT page 1", md)
            self.assertIn("OCR-TEXT page 2", md)
            self.assertNotIn("OCR REQUIRED: page 1", md)

    @unittest.skipUnless(POSIX, "shell metacharacter test needs a POSIX shell")
    def test_ocr_cmd_no_shell_injection_from_filename(self):
        """A hostile filename must never execute shell through --ocr-cmd."""
        marker = Path.cwd() / "pdf_read_pwned_marker"
        if marker.exists():
            marker.unlink()
        try:
            with tempfile.TemporaryDirectory() as tmp:
                evil = Path(tmp) / "evil;touch pdf_read_pwned_marker;.pdf"
                evil.write_bytes(SCANNED.read_bytes())
                out = Path(tmp) / "s.md"
                proc = run_pdf_read(
                    str(evil), "--out", str(out), "--ocr-cmd", "cat {input} > {out}"
                )
                self.assertEqual(proc.returncode, 0, proc.stderr)
                self.assertFalse(
                    marker.exists(), "shell injection via filename!"
                )
                self.assertTrue(out.exists())
        finally:
            if marker.exists():
                marker.unlink()

    def test_pages_selection_scopes_fail_on_ocr(self):
        # MIXED: page 1 needs OCR, page 2 is real text. Selecting page 2
        # only must not trigger --fail-on-ocr.
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "m.md"
            proc = run_pdf_read(
                str(MIXED), "--pages", "2", "--fail-on-ocr", "--out", str(out)
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
            md = out.read_text(encoding="utf-8")
            self.assertNotIn("OCR REQUIRED", md)
            self.assertIn("<!-- Page 2 -->", md)

    def test_json_without_stdout(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "m.md"
            proc = run_pdf_read(str(MIXED), "--json", "--out", str(out))
            self.assertEqual(proc.returncode, 0, proc.stderr)
            meta = json.loads(proc.stdout)
            self.assertEqual(meta["pdf_type"], "mixed")
            self.assertNotIn("markdown", meta)  # content stays in the file

    @unittest.skipUnless(HAS_ATTENTION, NEED_DOWNLOADED)
    def test_no_page_markers(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "n.md"
            proc = run_pdf_read(str(ATTENTION), "--pages", "1", "--out", str(out),
                                "--no-page-markers")
            self.assertEqual(proc.returncode, 0, proc.stderr)
            md = out.read_text(encoding="utf-8")
            self.assertNotIn("<!-- Page", md)
            self.assertIn("Attention Is All You Need", md)

    def test_chunks_zero_is_usage_error(self):
        proc = run_pdf_read(str(ONE_PAGE), "--chunks", "0")
        self.assertEqual(proc.returncode, 2)

    def test_chunks_too_small_is_usage_error(self):
        proc = run_pdf_read(str(ONE_PAGE), "--chunks", "10")
        self.assertEqual(proc.returncode, 2)
        self.assertIn("at least 64", proc.stderr)

    @unittest.skipUnless(HAS_ONE_PAGE, NEED_DOWNLOADED)
    def test_blank_pages_is_usage_error(self):
        proc = run_pdf_read(str(ONE_PAGE), "--pages", "")
        self.assertEqual(proc.returncode, 2)

    def test_selected_ocr_page_triggers_fail_on_ocr(self):
        # Selecting the page that genuinely needs OCR must exit 3.
        proc = run_pdf_read(str(MIXED), "--pages", "1", "--fail-on-ocr")
        self.assertEqual(proc.returncode, 3)

    def test_fail_on_ocr_stdout_mode_emits_nothing(self):
        # A rerouted run must not emit partial markdown/envelope.
        proc = run_pdf_read(str(SCANNED), "--json", "--stdout", "--fail-on-ocr")
        self.assertEqual(proc.returncode, 3)
        self.assertEqual(proc.stdout, "")
        self.assertIn("rerouting to OCR", proc.stderr)

    def test_fail_on_ocr_file_mode_writes_nothing(self):
        # Exit 3 must not leave partial .md/.meta.json/chunks behind.
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "s.md"
            proc = run_pdf_read(str(SCANNED), "--fail-on-ocr", "--out", str(out))
            self.assertEqual(proc.returncode, 3)
            self.assertFalse(out.exists())
            self.assertFalse(Path(str(out) + ".meta.json").exists())

    def test_classify_fail_on_ocr(self):
        proc = run_pdf_read(str(SCANNED), "--classify", "--fail-on-ocr")
        self.assertEqual(proc.returncode, 3)

    @unittest.skipUnless(HAS_ONE_PAGE, NEED_DOWNLOADED)
    def test_classify_fail_on_ocr_text_pdf_passes(self):
        proc = run_pdf_read(str(ONE_PAGE), "--classify", "--fail-on-ocr")
        self.assertEqual(proc.returncode, 0)

    @unittest.skipUnless(POSIX, "OCR hook uses a POSIX shell command")
    def test_fail_on_ocr_passes_after_successful_ocr_hook(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "s.md"
            proc = run_pdf_read(
                str(SCANNED),
                "--fail-on-ocr",
                "--out",
                str(out),
                "--ocr-cmd",
                'printf "OCR-TEXT page {page}" > {out}',
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)

    @unittest.skipUnless(POSIX, "OCR hook uses a POSIX shell command")
    def test_chunks_include_ocr_spliced_text(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "s.md"
            proc = run_pdf_read(
                str(SCANNED),
                "--out",
                str(out),
                "--chunks",
                "500",
                "--ocr-cmd",
                'printf "OCR-TEXT page {page}" > {out}',
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
            chunk_files = sorted(Path(tmp).glob("s.chunk-*.md"))
            self.assertTrue(chunk_files)
            all_text = "".join(f.read_text(encoding="utf-8") for f in chunk_files)
            self.assertIn("OCR-TEXT page 1", all_text)

    def test_json_stdout_stderr_pure_json_under_warnings(self):
        # The chunks-ignored warning must be buffered into the envelope,
        # not written to stderr, so stderr stays parseable JSON.
        proc = run_pdf_read(str(SCANNED), "--json", "--stdout", "--chunks", "1000")
        self.assertEqual(proc.returncode, 0, proc.stderr)
        meta = json.loads(proc.stderr)
        self.assertIn("warnings", meta)
        self.assertTrue(
            any("--chunks" in w for w in meta["warnings"]),
            meta["warnings"],
        )

    @unittest.skipUnless(HAS_ATTENTION, NEED_DOWNLOADED)
    def test_chunks_with_no_page_markers(self):
        # --no-page-markers must not silently produce zero chunk files.
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "n.md"
            proc = run_pdf_read(
                str(ATTENTION), "--pages", "1-3", "--no-page-markers",
                "--out", str(out), "--chunks", "500",
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
            manifest_path = Path(str(out) + ".chunks.json")
            self.assertTrue(manifest_path.exists())
            chunks = json.loads(manifest_path.read_text(encoding="utf-8"))
            self.assertGreater(len(chunks), 0)

    @unittest.skipUnless(POSIX, "uses the POSIX 'false' command")
    def test_meta_json_contains_buffered_warnings(self):
        # In --json file mode, the .meta.json must include buffered warnings
        # (here: the failing OCR command on every scanned page).
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "s.md"
            proc = run_pdf_read(
                str(SCANNED), "--json", "--out", str(out), "--ocr-cmd", "false"
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
            meta = json.loads(Path(str(out) + ".meta.json").read_text(encoding="utf-8"))
            self.assertTrue(
                any("OCR command failed" in w for w in meta["warnings"]),
                meta["warnings"],
            )

    @unittest.skipUnless(POSIX, "shell metacharacter test needs a POSIX shell")
    def test_placeholder_text_in_filename_is_not_rescanned(self):
        """A filename containing '{out}' must not corrupt the OCR template."""
        with tempfile.TemporaryDirectory() as tmp:
            tricky = Path(tmp) / "{out}.pdf"
            tricky.write_bytes(SCANNED.read_bytes())
            out = Path(tmp) / "s.md"
            proc = run_pdf_read(
                str(tricky), "--out", str(out), "--ocr-cmd", "cat {input} > {out}"
            )
            self.assertEqual(proc.returncode, 0, proc.stderr)
            self.assertTrue(out.exists())
            md = out.read_text(encoding="utf-8")
            self.assertIn("<!-- OCR page 1:", md)

    def test_blank_ocr_cmd_is_usage_error(self):
        proc = run_pdf_read(str(ONE_PAGE), "--ocr-cmd", "   ")
        self.assertEqual(proc.returncode, 2)

    def test_unwritable_output_is_clean_error(self):
        # SCANNED is a committed fixture, so this works on fresh clones too.
        proc = run_pdf_read(
            str(SCANNED), "--out", "/nonexistent-dir-xyz/out.md"
        )
        self.assertEqual(proc.returncode, 1)
        self.assertIn("cannot write output", proc.stderr)


class TestMixedRouting(unittest.TestCase):
    def test_mixed_per_page_routing(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "m.md"
            proc = run_pdf_read(str(MIXED), "--out", str(out))
            self.assertEqual(proc.returncode, 0, proc.stderr)
            md = out.read_text(encoding="utf-8")
            self.assertIn("<!-- OCR REQUIRED: page 1 has no reliable embedded text -->", md)
            self.assertNotIn("OCR REQUIRED: page 2", md)
            self.assertIn("<!-- Page 2 -->", md)
            # page 2 must carry real extracted text, not just markers
            page2 = md.split("<!-- Page 2 -->", 1)[1]
            self.assertGreater(len(page2.strip()), 100)

    def test_json_stdout_contract(self):
        proc = run_pdf_read(str(MIXED), "--json", "--stdout")
        self.assertEqual(proc.returncode, 0, proc.stderr)
        meta = json.loads(proc.stderr)  # envelope on stderr keeps stdout pure
        self.assertEqual(meta["pdf_type"], "mixed")
        self.assertIn("pages_needing_ocr", meta)
        self.assertIn("markdown", meta)
        self.assertIn("OCR REQUIRED", proc.stdout)  # markdown on stdout


class TestInstallScript(unittest.TestCase):
    """Command-construction tests for scripts/install.py (no network)."""

    def _load_install(self):
        spec = importlib.util.spec_from_file_location(
            "pdf_read_install", SKILL_DIR / "scripts" / "install.py"
        )
        mod = importlib.util.module_from_spec(spec)
        assert spec.loader is not None
        spec.loader.exec_module(mod)
        return mod

    def test_upgrade_flag_construction(self):
        mod = self._load_install()
        captured: list[list[str]] = []

        def fake_run(cmd):
            captured.append(cmd)
            return True

        with mock.patch.object(mod, "run", side_effect=fake_run), mock.patch.object(
            mod.shutil, "which", side_effect=lambda name: "/usr/bin/" + name
        ):
            mod.install_python(False)
            mod.install_python(True)
            mod.install_cli(True)
            mod.install_node(True)
        # plain pip install: no --upgrade, package last
        self.assertEqual(captured[0][-1], "pdf-inspector")
        self.assertNotIn("--upgrade", captured[0])
        # pip --upgrade
        self.assertIn("--upgrade", captured[1])
        # cargo install --force pdf-inspector
        self.assertEqual(captured[2][:2], ["cargo", "install"])
        self.assertIn("--force", captured[2])
        # npm @latest for both packages
        self.assertTrue(captured[3][-1].endswith("@latest"))
        self.assertTrue(captured[4][-1].endswith("@latest"))

    def test_upgrade_flag_short_circuits_with_check(self):
        mod = self._load_install()
        rc = mod.main(["--check", "--upgrade"])
        self.assertEqual(rc, 0)


if __name__ == "__main__":
    unittest.main()