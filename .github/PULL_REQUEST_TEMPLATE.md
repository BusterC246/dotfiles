name: Pull Request
description: Submit a pull request
labels: ["enhancement"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for opening a PR!
  - type: input
    id: description
    attributes:
      label: Description
      description: What does this PR do?
    validations:
      required: true
  - type: checkboxes
    id: checks
    attributes:
      label: Checks
      description: Please confirm the following.
      options:
        - label: I ran `./sync.sh --simulate` and it passed
          required: true
        - label: I ran shellcheck on any shell scripts I changed
          required: true
        - label: No secrets, passwords, or API keys are included
          required: true
