#!/usr/bin/env python3
"""Generate synthetic scanned/mixed PDF fixtures for the test suite.

- scanned_sample.pdf : 2 image-only pages (no text operators) -> image_based
- mixed_sample.pdf   : page 1 = image-only, page 2 = real text -> mixed

Idempotent: regenerates only when the fixture files are missing.
Run: python tests/make_fixtures.py
"""
from __future__ import annotations

import sys
from pathlib import Path

FIXTURES = Path(__file__).parent / "fixtures"
SCANNED = FIXTURES / "scanned_sample.pdf"
MIXED = FIXTURES / "mixed_sample.pdf"

FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Arial.ttf",  # macOS
    "/System/Library/Fonts/Helvetica.ttc",           # macOS
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",  # Linux
    "C:/Windows/Fonts/arial.ttf",                    # Windows
]


def make_image_only_pdf(path: Path) -> None:
    from PIL import Image, ImageDraw, ImageFont

    font = None
    for candidate in FONT_CANDIDATES:
        if Path(candidate).exists():
            try:
                font = ImageFont.truetype(candidate, 36)
                break
            except OSError:
                continue
    images = []
    for page in (1, 2):
        img = Image.new("RGB", (1240, 1754), "white")  # A4 @ ~150dpi
        draw = ImageDraw.Draw(img)
        draw.text(
            (80, 80),
            f"SCANNED PAGE {page}\nThis page is a raster image.",
            fill="black",
            font=font,
        )
        for i in range(5):  # some fake "text lines" blocks
            y = 300 + i * 200
            draw.rectangle([80, y, 1160, y + 90], outline="gray", width=3)
            draw.text((100, y + 20), f"line {i + 1} of page {page}", fill="black", font=font)
        images.append(img)
    # Pillow saves multi-image PDF; first image sets page size.
    images[0].save(path, "PDF", resolution=150, save_all=True, append_images=images[1:])


def make_mixed_pdf(path: Path) -> None:
    from pypdf import PdfReader, PdfWriter

    text_pdf = FIXTURES / "government_positions_women.pdf"
    if not text_pdf.exists():
        raise SystemExit(
            f"missing text fixture {text_pdf} — re-run after downloading fixtures"
        )
    writer = PdfWriter()
    writer.append(str(SCANNED), pages=(0, 1))  # image-only page 1
    writer.append(str(text_pdf), pages=(0, 1))  # real text page 2
    with open(path, "wb") as fh:
        writer.write(fh)


def main() -> int:
    FIXTURES.mkdir(parents=True, exist_ok=True)
    if not SCANNED.exists():
        print(f"generating {SCANNED.name} ...")
        make_image_only_pdf(SCANNED)
    if not MIXED.exists():
        if not SCANNED.exists():
            raise SystemExit("scanned_sample.pdf must exist first")
        print(f"generating {MIXED.name} ...")
        make_mixed_pdf(MIXED)
    print("fixtures ready")
    return 0


if __name__ == "__main__":
    sys.exit(main())
