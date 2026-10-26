# pdf_read.py — CLI reference

The core executable of this skill. Runs on macOS / Linux / Windows with
CPython ≥ 3.8 and the `pdf-inspector` package (`pip install pdf-inspector`,
prebuilt wheels, no Rust toolchain).

## Usage

> Commands below assume your shell is inside the skill folder (typical after
> a copy-install). From the repo root, prefix with `skills/pdf-reader/`.

```bash
python scripts/pdf_read.py <document.pdf>                 # → <document>.md + <document>.md.meta.json
python scripts/pdf_read.py <document.pdf> --classify      # type/confidence/pages_needing_ocr only
python scripts/pdf_read.py <document.pdf> --pages 1,3,5-10
python scripts/pdf_read.py <document.pdf> --chunks 8000
python scripts/pdf_read.py <document.pdf> --json --stdout # Markdown→stdout, JSON→stderr
python scripts/pdf_read.py <document.pdf> --ocr-cmd 'tesseract {input} stdout -l eng'
python scripts/pdf_read.py <document.pdf> --fail-on-ocr   # exit 3 if pages still lack text
python scripts/pdf_read.py --version
```

## Options

| Option | Meaning |
|---|---|
| `--out FILE` | output Markdown path (default `<input>.md`) |
| `--pages SPEC` | 1-indexed pages, e.g. `1,3,5-10` (cap: 100 000 pages) |
| `--classify` | classification only; no extraction |
| `--json` | machine-readable envelope (stdout; stderr with `--stdout`) |
| `--stdout` | print Markdown to stdout instead of writing files |
| `--chunks MAX_TOKENS` | also write ≤ MAX_TOKENS-token chunk files + `<out>.chunks.json` manifest (min 64) |
| `--ocr-cmd TEMPLATE` | shell command for pages needing OCR; placeholders `{input} {page} {out} {stem} {outdir}`, shell-quoted automatically — use them bare |
| `--fail-on-ocr` | exit 3 before any output when pages still lack reliable text (after the hook, if given) |
| `--no-page-markers` | omit `<!-- Page N -->` markers |

## Output contract

- Markdown contains `<!-- Page N -->` markers for citing; `|` tables are real
  Markdown tables; `#`-level headings reflect the PDF's font sizes.
- Pages without embedded text are flagged
  `<!-- OCR REQUIRED: page N has no reliable embedded text -->` — never
  guess their content.
- `<document>.md.meta.json` carries `pdf_type`, `confidence`, `page_count`,
  `pages_needing_ocr`, `pages_with_tables`, `pages_with_columns`,
  `ocr_pages`, `warnings`.
- With `--json --stdout`: Markdown on stdout, JSON envelope on stderr
  (stderr is pure JSON — warnings are buffered into the envelope).
- Control characters are stripped from all output; OCR text is sanitized;
  shell templates are injection-safe (single-pass substitution + automatic
  quoting; Windows rejects `%`/`!` in values).

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success (OCR-needing pages reported, not fatal) |
| 1 | error: missing file, unreadable/encrypted PDF, dependency missing, write failure |
| 2 | usage error (bad `--pages`, blank `--ocr-cmd`, `--chunks < 64`) |
| 3 | `--fail-on-ocr`: pages still need OCR (nothing written) |

## Resource bounds

- OCR subprocess: stdout/stderr stream to files, read capped at 64 MiB/page;
  600 s timeout with process-group kill.
- Page selections capped at 100 000 pages (per-range and cumulative).
- No network access; runs fully local.
