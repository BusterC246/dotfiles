# Rules for AI agents using pdf-reader

These rules govern how an agent should consume the Markdown produced by
`scripts/pdf_read.py`.

## Reading the output

1. **Read the Markdown, not the PDF.** Run `scripts/pdf_read.py`, then read
   the generated `.md` (or pipe `--stdout`).
2. **Cite pages.** `<!-- Page N -->` markers give exact source pages — say
   which page a passage came from when quoting.
3. **Tables are real Markdown.** Read `|` tables as tables with headers and
   cells, never as prose.
4. **Headings are font-size-based.** `#`/`##`/`###` reflect the original
   document's heading hierarchy.
5. **Never trust OCR-flagged pages.** `<!-- OCR REQUIRED: page N -->` means
   page N has no embedded text — do not guess its content. Either report
   that page N needs OCR, or run the `--ocr-cmd` hook (e.g.
   `tesseract {input} stdout -l eng`).
6. **Respect context limits.** For long documents use `--chunks N` and read
   the chunk files one at a time; keep page markers when quoting.

## Quality checks before answering

- Spot-check 2–3 headings and 1 table against the document's known
  structure. If the Markdown looks broken, say so — never silently work
  from bad data.
- If `pages_needing_ocr` is non-empty, mention it; never invent content for
  those pages.
- For huge PDFs (hundreds of pages), prefer `--pages` or `--chunks` over
  reading everything at once.
- Equations extract as inline glyphs; preserve them but don't "fix" math
  notation silently.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `pdf_inspector is not installed` | `python -m pip install pdf-inspector` (see README.md) |
| Exit 1, "password-protected or malformed" | encrypted PDF — unlock it first |
| `type=scanned` with all pages flagged | genuinely scanned; run `--ocr-cmd` or tell the user OCR is needed |
| `confidence` low (< 0.7) on mixed docs | check `pages_needing_ocr`; treat flagged pages as unreadable |
| `--ocr-cmd` fails on Windows paths with `%`/`!` | pdf_read rejects them (cmd.exe cannot quote them); rename the file |
