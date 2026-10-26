# Contributing

Thanks for considering a contribution to this dotfiles repository.

This is a personal configuration repo managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package that gets linked into `$HOME`. The goal is to keep configs portable, shareable, and free of hardware-specific or personal information.

## How to contribute

1. **Fork the repo** and clone your fork.
2. **Make your change** — keep it small and focused.
3. **Test it** — run `./sync.sh --simulate` to make sure stow won't break anything.
4. **Run shellcheck** on any shell scripts you touch.
5. **Commit** with a clear message and push to your fork.
6. **Open a pull request** — describe what you changed and why.

## What to avoid

- **Don't add secrets** — no passwords, API keys, tokens, or `service.json` files. These belong in `.gitignore`, not the repo.
- **Don't hardcode paths** like `/home/yourname/...`. Use `$HOME` or environment variables instead.
- **Don't add machine-specific config** (monitor names, GPU driver paths) unless it's behind an env var with a sensible default.

## Code style

- Shell scripts must be POSIX-compliant (`sh`, not `bash`-isms).
- Use `$XDG_CONFIG_HOME`, `$XDG_DATA_HOME`, etc. where possible.
- Defaults are fine — make them overridable via environment variables.

## License

By contributing, you agree that your contributions will be licensed under the GPL-3.0 license that covers this project.
