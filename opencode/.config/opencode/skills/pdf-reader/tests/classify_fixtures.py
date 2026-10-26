#!/usr/bin/env python3
"""Classify all fixture PDFs and print ground-truth summary (dev helper)."""
import json
import sys
from pathlib import Path

import pdf_inspector

FIXTURES = Path(__file__).parent / "fixtures"


def main() -> int:
    rows = []
    for pdf in sorted(FIXTURES.glob("*.pdf")):
        try:
            c = pdf_inspector.classify_pdf(str(pdf))
            rows.append(
                {
                    "file": pdf.name,
                    "pdf_type": c.pdf_type,
                    "confidence": round(c.confidence, 3),
                    "page_count": c.page_count,
                    "pages_needing_ocr": sorted(
                        p + 1 for p in c.pages_needing_ocr
                    ),
                }
            )
        except Exception as exc:  # noqa: BLE001
            rows.append({"file": pdf.name, "error": str(exc)})
    print(json.dumps(rows, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
