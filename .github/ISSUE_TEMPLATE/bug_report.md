name: Bug Report
description: Create a report to help us improve
labels: ["bug"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this bug report!
  - type: input
    id: what-happened
    attributes:
      label: What happened?
      description: Tell us what went wrong.
      placeholder: "e.g., `sync.sh` fails on stow for hyprland"
    validations:
      required: true
  - type: input
    id: expected
    attributes:
      label: What did you expect to happen?
      description: Tell us what should have happened.
    validations:
      required: true
  - type: input
    id: steps
    attributes:
      label: Steps to reproduce
      description: How can we reproduce the issue?
      placeholder: |
        1. `git clone https://github.com/USERNAME/dotfiles.git`
        2. `cd dotfiles`
        3. `./sync.sh`
    validations:
      required: false
  - type: input
    id: environment
    attributes:
      label: Environment
      description: What OS/distro and shell are you using?
      placeholder: "e.g., Arch Linux, zsh, Hyprland"
    validations:
      required: false
