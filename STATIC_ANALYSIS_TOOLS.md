# Static Analysis Tools Used in This Project

This project uses a set of modern static analysis tools to ensure code quality, security, and maintainability. Below is a description of each tool and its purpose.

---

## 1. [pre-commit](https://pre-commit.com/)
**Purpose:** Framework for managing and maintaining multi-language pre-commit hooks.
- Automatically runs checks before every commit.
- Ensures all code passes formatting, linting, and security checks before entering the repository.

---

## 2. [black](https://github.com/psf/black)
**Purpose:** Python code formatter.
- Enforces a consistent code style for Python files.
- Automatically reformats code to follow the "Black" style guide (PEP8+).
- Reduces code review friction by standardizing formatting.

---

## 3. [flake8](https://flake8.pycqa.org/)
**Purpose:** Python linter and style checker.
- Checks for syntax errors, undefined variables, and code style issues.
- Enforces PEP8 and other configurable rules.
- In this project, line length checks (E501) are disabled to match Black's style.

---

## 4. [yamllint](https://github.com/adrienverge/yamllint)
**Purpose:** YAML linter.
- Checks YAML files for syntax errors, formatting issues, and best practices.
- Helps prevent configuration errors in Kubernetes manifests and CI/CD configs.

---

## 5. [shellcheck](https://www.shellcheck.net/)
**Purpose:** Shell script static analysis.
- Detects syntax errors, bad practices, and potential bugs in bash/sh scripts.
- Recommends safer and more portable shell scripting patterns.

---

## 6. [hadolint](https://github.com/hadolint/hadolint)
**Purpose:** Dockerfile linter.
- Checks Dockerfiles for best practices, security issues, and common mistakes.
- Warns about unpinned versions, use of cache, and other Docker anti-patterns.

---

## 7. [detect-secrets](https://github.com/Yelp/detect-secrets)
**Purpose:** Secret detection tool.
- Scans code and configuration files for accidentally committed secrets, passwords, API keys, and tokens.
- Helps prevent credential leaks in the repository.

---

## How to Use
- All these tools are managed via `pre-commit` and run automatically before each commit.
- To run all checks manually:
  ```bash
  pre-commit run --all-files
  ```
- If any check fails, fix the issues and recommit.

---

**Maintaining high code quality and security is a team effort. These tools help automate and enforce best practices at every step!** 