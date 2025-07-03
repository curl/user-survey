# Format

The markdown files in this repository follow a simply layout that is intended
to be both readable and easy to convert into whatever format we might need to
host a survey.

Each markdown file holds a single question. The order of the questions are
simply the order they are listed in the `README.md` file. Each question is
independent.

## Syntax

    ---
    Type: [check-boxes/radio-buttons/text]
    Other: yes (if provided, adds an "Other:" choice for user to add text)
    ---
    
    # The question
    
    extra information and details
    
    - option 1
    - option 2
    - ...
