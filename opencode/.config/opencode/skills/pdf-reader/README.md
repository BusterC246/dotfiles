# pdf-reader — accurate PDF → Markdown for AI agents

> Part of [https://github.com/vichhka-git/pdf-reader-skills](https://github.com/vichhka-git/pdf-reader-skills) —
> install this folder into your agent as-is.

Most AI models cannot open PDFs, and naive converters mangle columns, tables,
and headings — which makes the model misread the document. This skill uses
**[pdf-inspector](https://github.com/firecrawl/pdf-inspector)** (Firecrawl's
Rust engine, benchmark #1 on the opendataloader-bench corpus: reading order
0.915, tables 0.814, ~2.8 s for 200 documents) to turn PDFs into clean,
position-aware Markdown — headings, lists, code blocks, tables, multi-column
reading order — *without OCR* for text-based PDFs, and with per-page OCR
routing for scanned ones.

```
pdf-reader/
├── SKILL.md              ← main orchestrator (the agent playbook)
├── README.md             ← this file: quick start + installation
├── scripts/
│   ├── pdf_read.py       ← core CLI the skill calls
│   └── install.py        ← one-shot binding installer (pip/cargo/npm)
├── references/
│   ├── api-guide.md      ← CLI reference (options, output contract)
│   └── rules.md          ← rules for AI agents using the output
└── tests/                ← test suite + fixtures
```

## 1. Prerequisites (tools you need first)

| Tool | Required | Why |
|---|---|---|
| **Python ≥ 3.8** | ✅ required | Runs `pdf_read.py` and the `pdf-inspector` Python binding. Check: `python3 --version` |
| **pip** | ✅ required | Installs the binding (ships with Python; on some Linux distros install `python3-pip`). Check: `python3 -m pip --version` |
| Node.js + npm | optional | Only if you want the Node/WebAssembly bindings (`--node`) |
| Rust toolchain (cargo) | optional | Only if you want the upstream `pdf2md` CLI (`--cli`) |

No Rust toolchain is needed for the default install — `pdf-inspector` ships
prebuilt wheels for macOS (Intel + Apple Silicon), Linux (x86_64 + aarch64),
and Windows (x64).

## 2. Install pdf-inspector (step by step)

> Run these commands from **inside this `pdf-reader/` folder** (or prefix the
> python commands with `skills/pdf-reader/` when working from the repo root).

```bash
# 1. (recommended) create a virtual environment so nothing global changes
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate

# 2. install the binding — prebuilt wheel, no compilation
python -m pip install pdf-inspector

# 3. verify the API is importable
python scripts/install.py --check
#   → "pdf_inspector: OK (importable)"
```

Optional bindings:

```bash
python scripts/install.py --all   # also tries cargo (pdf2md CLI) + npm (Node/wasm)
```

### Updating pdf-inspector

Installs are **not pinned**: a plain run installs the latest release at that
moment, but an existing install is left untouched (pip does not auto-upgrade).
When pdf-inspector ships a new release:

```bash
python scripts/install.py --upgrade            # pip -U (Python binding)
python scripts/install.py --upgrade --all      # + npm @latest, cargo --force
python scripts/install.py --check              # confirm the new version is importable
```

The `pdf_read.py` wrapper targets the stable 0.2.x Python API; if a future
pdf-inspector release breaks the API, upgrade the wrapper alongside the
binding (both live in this skill folder).

Manual equivalents: `python -m pip install pdf-inspector` (Python) ·
`cargo install pdf-inspector` (CLI) · `npm install @firecrawl/pdf-inspector`
(Node) · `npm install @firecrawl/pdf-inspector-wasm` (browser).

## 3. Quick start

```bash
python scripts/pdf_read.py document.pdf              # → document.md + document.md.meta.json
python scripts/pdf_read.py document.pdf --classify   # text vs scanned?
python scripts/pdf_read.py document.pdf --pages 1,3,5-10
python scripts/pdf_read.py document.pdf --chunks 8000
python scripts/pdf_read.py document.pdf --json --stdout   # Markdown→stdout, JSON→stderr
```

What you get:

```markdown
<!-- Page 1 -->

# 1 Introduction

The dominant sequence transduction models are based on ...

| Model | EN-DE | EN-FR |
|---|---|---|
| Transformer (base) | 27.3 | 38.1 |
```

`document.md.meta.json` carries `pdf_type`, `confidence`, `page_count`,
`pages_needing_ocr`, `pages_with_tables`, `pages_with_columns`, `warnings`.

### Exit codes

| Code | Meaning |
|---|---|
| 0 | Success (pages needing OCR are reported in the meta, not fatal) |
| 1 | Error: missing file, unreadable/encrypted PDF, dependency missing |
| 2 | Usage error (bad `--pages`, blank `--ocr-cmd`, `--chunks < 64`) |
| 3 | `--fail-on-ocr`: pages still lack reliable text after the `--ocr-cmd` hook |

## 4. OCR routing (scanned / mixed PDFs)

```bash
python scripts/pdf_read.py scan.pdf --classify
# pdf_read: scan.pdf — type=scanned confidence=0.95 pages=2 pages_needing_ocr=[1, 2]
```

Pages without embedded text are flagged `<!-- OCR REQUIRED: page N -->` in
the Markdown — never guessed. Fill them with a local OCR engine:

```bash
python scripts/pdf_read.py document.pdf --ocr-cmd 'tesseract {input} stdout -l eng'
```

Placeholders `{input} {page} {out} {stem} {outdir}` are **shell-quoted
automatically** — use them bare, never wrapped in quotes. Text is read from
`{out}` if the command writes it, else from stdout. `--fail-on-ocr` exits 3
before writing anything when pages still lack text, so pipelines can reroute.

## 5. Using it from an AI agent

1. Read the Markdown, not the PDF — run `scripts/pdf_read.py`, then read the `.md` (or pipe `--stdout`).
2. Cite pages — `<!-- Page N -->` markers give exact source pages.
3. Never trust OCR-flagged pages — run `--ocr-cmd` or tell the user page N needs OCR.
4. Respect context limits — `--chunks N` writes ≤N-token chunk files + a manifest (`<out>.chunks.json`).
5. Tables are real Markdown — read them as tables, not prose.
6. Verify — spot-check headings and key terms survived; page markers should be sequential.

## 6. Tests

```bash
make test                        # from the repo root (39 tests)
# or, inside this folder:
python -m unittest discover -s tests -v
```

The suite covers extraction accuracy (headings, tables, phrases from a real
research paper), page selection, chunk-budget guarantees, scanned/mixed OCR
routing, the OCR hook, shell-injection safety, the JSON contract, and error
paths.

## Limitations

- Scanned/image PDFs have no text to extract — pdf-inspector is not an OCR
  engine; it routes those pages to OCR for you (per-page).
- Equations (LaTeX math) extract as inline glyphs; structure is preserved but
  math notation may look odd.
- Encrypted PDFs must be unlocked before processing.
- Very large documents are bounded only by available memory; use `--pages` or
  `--chunks` for huge files.

## License

MIT. pdf-inspector is MIT © Firecrawl.
