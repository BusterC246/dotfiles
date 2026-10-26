name: Feature Request
description: Suggest an idea for this project
labels: ["enhancement"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for suggesting a feature!
  - type: input
    id: feature
    attributes:
      label: Feature
      description: What would you like to see added or changed?
    validations:
      required: true
  - type: textarea
    id: motivation
    attributes:
      label: Motivation
      description: Why is this useful? What problem does it solve?
    validations:
      required: false
