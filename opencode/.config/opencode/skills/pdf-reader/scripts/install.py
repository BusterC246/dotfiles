#!/usr/bin/env python3
"""install.py — install pdf-inspector bindings on any OS.

pdf-inspector ships official bindings for four runtimes; this helper detects
what is available on the machine and installs the matching one(s):

  Python  : pip install pdf-inspector        (required by pdf_read.py)
  Rust CLI: cargo install pdf-inspector      (upstream pdf2md / detect-pdf)
  Node.js : npm install @firecrawl/pdf-inspector (+ -wasm for browsers)

Cross-platform: macOS / Linux / Windows. Requires Python >= 3.8 to run.

Usage:
  python3 install.py             auto-install the Python binding (needed)
  python3 install.py --cli       also install the Rust CLI (needs cargo)
  python3 install.py --node      also install Node bindings (needs npm)
  python3 install.py --all       try everything available
  python3 install.py --upgrade   upgrade existing bindings to the latest
                                 release (pip -U / npm @latest / cargo --force)
  python3 install.py --check     report what is installed without changing

Note: installs are NOT pinned — a plain run installs the latest release at
that moment, but an existing install is left untouched. Use --upgrade to
pull a newer pdf-inspector release.
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys


def run(cmd: list[str]) -> bool:
    sys.stderr.write("$ " + " ".join(cmd) + "\n")
    try:
        proc = subprocess.run(cmd, text=True)
    except FileNotFoundError:
        sys.stderr.write(f"  command not found: {cmd[0]}\n")
        return False
    return proc.returncode == 0


def check_python() -> None:
    sys.stderr.write("== Python binding ==" + "\n")
    try:
        import pdf_inspector  # noqa: F401

        sys.stderr.write("  pdf_inspector: OK (importable)\n")
    except (ImportError, OSError) as exc:  # OSError = broken native .so
        sys.stderr.write(f"  pdf_inspector: not usable ({exc})\n")


def check_cli() -> None:
    sys.stderr.write("== Rust CLI ==" + "\n")
    if shutil.which("pdf2md"):
        sys.stderr.write("  pdf2md: OK\n")
    else:
        sys.stderr.write("  pdf2md: not installed\n")


def check_node() -> None:
    sys.stderr.write("== Node.js bindings ==" + "\n")
    node = shutil.which("node")
    npm = shutil.which("npm")
    if not node or not npm:
        sys.stderr.write("  node/npm: not found\n")
        return
    for pkg in ("@firecrawl/pdf-inspector", "@firecrawl/pdf-inspector-wasm"):
        try:
            proc = subprocess.run(
                [npm, "ls", pkg], capture_output=True, text=True, check=False
            )
            if pkg in proc.stdout:
                sys.stderr.write(f"  {pkg}: OK\n")
            else:
                sys.stderr.write(f"  {pkg}: not installed\n")
        except FileNotFoundError:
            sys.stderr.write(f"  {pkg}: npm not found\n")


def install_python(upgrade: bool = False) -> bool:
    cmd = [sys.executable, "-m", "pip", "install"]
    if upgrade:
        cmd.append("--upgrade")
    cmd.append("pdf-inspector")
    return run(cmd)


def install_cli(upgrade: bool = False) -> bool:
    if not shutil.which("cargo"):
        sys.stderr.write(
            "  cargo not found — Rust CLI needs a Rust toolchain "
            "(https://rustup.rs). Skipping.\n"
        )
        return False
    cmd = ["cargo", "install"]
    if upgrade:
        cmd.append("--force")  # reinstall even if the same version is present
    cmd.append("pdf-inspector")
    return run(cmd)


def install_node(upgrade: bool = False) -> bool:
    npm = shutil.which("npm")
    if not npm:
        sys.stderr.write("  npm not found. Skipping Node bindings.\n")
        return False
    suffix = "@latest" if upgrade else ""
    ok = run([npm, "install", f"@firecrawl/pdf-inspector{suffix}"])
    ok = run([npm, "install", f"@firecrawl/pdf-inspector-wasm{suffix}"]) and ok
    return ok


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="install.py",
        description="Install pdf-inspector bindings (pip / cargo / npm / wasm).",
    )
    parser.add_argument("--cli", action="store_true", help="install Rust CLI via cargo")
    parser.add_argument(
        "--node", action="store_true", help="install Node.js (+wasm) bindings via npm"
    )
    parser.add_argument(
        "--all", action="store_true", help="try every binding available on this machine"
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="report installed bindings without changing anything",
    )
    parser.add_argument(
        "--upgrade",
        "-U",
        action="store_true",
        help="upgrade existing bindings to the latest release "
        "(pip -U / npm @latest / cargo --force)",
    )
    args = parser.parse_args(argv)

    if args.check:
        check_python()
        check_cli()
        check_node()
        return 0

    results: list[tuple[str, bool]] = []
    results.append(("python", install_python(args.upgrade)))
    if args.all or args.cli:
        results.append(("cli", install_cli(args.upgrade)))
    if args.all or args.node:
        results.append(("node", install_node(args.upgrade)))

    failed = [name for name, ok in results if not ok]
    if failed:
        sys.stderr.write(
            "\nSome installs failed or were skipped: "
            + ", ".join(failed)
            + "\n"
        )
        return 1
    sys.stderr.write("\nAll requested bindings installed.\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
