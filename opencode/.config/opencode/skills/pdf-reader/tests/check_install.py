"""Verify pdf-inspector is importable and exposes the expected API surface."""
import pdf_inspector

required = [
    "process_pdf", "process_pdf_bytes", "detect_pdf", "classify_pdf",
    "extract_text", "extract_text_with_positions", "extract_pages_markdown",
    "extract_text_in_regions",
]
missing = [name for name in required if not hasattr(pdf_inspector, name)]
if missing:
    raise SystemExit(f"MISSING API: {missing}")

print(f"pdf-inspector OK: version={getattr(pdf_inspector, '__version__', 'unknown')}")
print(f"API surface: {len(required)} functions verified")
