---
name: pdf-reader
description: Convert PDFs to accurate Markdown for AI reading using pdf-inspector (Rust) — smart text/scanned classification, per-page OCR routing, page markers, and context-size chunking. Cross-platform (macOS/Linux/Windows).
---

# pdf-reader

Turn a PDF into clean, position-aware Markdown that an AI model can read
*without misreading the layout*. Backed by
[pdf-inspector](https://github.com/firecrawl/pdf-inspector) (Firecrawl's Rust
engine), which handles columns, tables, headings, lists, and code blocks, and
tells you exactly which pages (if any) need OCR.

## When to use

- The user shares or points at a PDF and asks you to read, summarize, extract,
  or quote from it — and your model cannot read PDFs natively.
- The PDF contains tables, multi-column layouts, or dense formatting where a
  naive text dump would corrupt the meaning.
- You need to cite specific pages of a document.

Do NOT use for image-only/scanned PDFs expecting embedded text: pdf-inspector
is not an OCR engine. It will classify them as `scanned`/`image_based` and
flag every page — that is the signal to route to OCR (`--ocr-cmd`) instead.

## Prerequisites

- Python 3 (≥ 3.8) with `pip install pdf-inspector` (prebuilt wheels for
  macOS Intel/ARM, Linux x86_64/aarch64, Windows x64 — no Rust toolchain).
- The core CLI is `scripts/pdf_read.py` — the `scripts/` folder sits NEXT
  TO this SKILL.md. Resolve it relative to this file:
  `<this-skill-folder>/scripts/pdf_read.py` (and
  `<this-skill-folder>/scripts/install.py` for one-shot installation).
  Reference docs live in `references/` (`api-guide.md`, `rules.md`).
  If the folder is missing, clone or copy it from the skill repo, or follow
  `README.md` step-by-step installation.

## Procedure

> `PDF_READ` below stands for `<this-skill-folder>/scripts/pdf_read.py` —
> the folder next to this SKILL.md.

1. **Locate the wrapper** — resolve `scripts/pdf_read.py` next to this
   file. If it is not present, tell the user it must be installed with the
   skill (`README.md` has the steps).
2. **Classify first** (fast, ~10–50 ms):
   ```bash
   python3 "$PDF_READ" <document.pdf> --classify
   ```
   Read the output: `type=text_based|scanned|image_based|mixed`,
   `confidence`, `pages_needing_ocr=[...]`.
3. **Convert** (default writes `<document>.md` + `<document>.md.meta.json`):
   ```bash
   python3 "$PDF_READ" <document.pdf>
   ```
   For a quick answer you may pipe instead:
   ```bash
   python3 "$PDF_READ" <document.pdf> --stdout --pages 1-10
   ```
4. **Read the Markdown**, honoring these rules:
   - `<!-- Page N -->` markers = source pages. When you quote or cite, say
     which page a passage came from.
   - `|` tables are real Markdown tables — read them as tables, with headers
     and cells, not as prose.
   - Headings are `#`/`##`/`###` (font-size-based from the original PDF).
   - `<!-- OCR REQUIRED: page N ... -->` means page N has **no embedded
     text**: do not guess its content. Either report that page N needs OCR,
     or run the OCR hook (step 5).
5. **OCR fallback for flagged pages** — run a local OCR engine per page:
   ```bash
   python3 "$PDF_READ" <document.pdf> --ocr-cmd 'tesseract {input} stdout -l eng'
   ```
   The hook output is spliced into the Markdown at the page's position.
   Placeholders (`{input}` `{page}` `{out}` `{stem}` `{outdir}`) are
   **shell-quoted automatically** — use them bare, never wrapped in quotes.
6. **Long documents / small context windows** — split into chunks:
   ```bash
   python3 "$PDF_READ" <document.pdf> --chunks 8000
   ```
   Reads `<document>.chunk-001.md`, `.chunk-002.md`, ... in order; the
   manifest `<document>.md.chunks.json` lists sizes and page ranges. Do not
   feed more than fits the model's context; keep the page markers when
   quoting.
7. **Machine-readable use** (pipelines, tools):
   ```bash
   python3 "$PDF_READ" <document.pdf> --json --stdout
   ```
   Markdown → stdout, JSON envelope → stderr. Exit codes: 0 ok (OCR pages
   reported, not fatal), 1 error, 2 usage, 3 `--fail-on-ocr`: pages still
   lack reliable text after the OCR hook (nothing is written on exit 3).

## Quality checks (do these before answering from the output)

- Spot-check 2–3 headings and 1 table against the original document's known
  structure; if the Markdown looks broken (garbled text, missing sections),
  mention it to the user instead of silently working from bad data.
- If `pages_needing_ocr` is non-empty, say so — never invent content for
  those pages.
- For huge PDFs (hundreds of pages), prefer `--pages` or `--chunks` over
  reading everything at once.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `pdf_inspector is not installed` | `python3 -m pip install pdf-inspector` |
| Exit 1, "password-protected or malformed" | encrypted PDF — unlock it first |
| `type=scanned` with all pages flagged | genuinely scanned; run `--ocr-cmd` or tell the user OCR is needed |
| `confidence` low (< 0.7) on mixed docs | check `pages_needing_ocr` and treat flagged pages as unreadable |
| Math looks odd | equations extract as inline glyphs; preserve them but don't "fix" silently |
