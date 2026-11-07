# Contributing to Sahaayi (സഹായി)

Thank you for your interest in contributing to Sahaayi! This project aims to make technology more accessible for elderly people and those with accessibility needs. Every contribution — from code to documentation to accessibility feedback — is valued.

Please take a moment to read through this guide before you begin.

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How to Report Issues](#how-to-report-issues)
3. [Development Workflow](#development-workflow)
4. [Branch Naming Conventions](#branch-naming-conventions)
5. [Commit Message Format](#commit-message-format)
6. [Pull Request Checklist](#pull-request-checklist)
7. [Code Review Process](#code-review-process)
8. [Two-Member Team Coordination](#two-member-team-coordination)
9. [Style Guides](#style-guides)

---

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). We expect all contributors to treat each other with respect and empathy, particularly given the sensitive nature of this project's focus on elderly and accessibility communities.

---

## How to Report Issues

### Bug Reports

Before filing a bug, please:
1. **Search existing issues** to avoid duplicates.
2. **Reproduce the bug** on the latest `main` branch.
3. **Gather relevant information**: device model, Android version, app version, logs.

When filing a bug report, use the **Bug Report** issue template and include:
- A clear, descriptive title
- Steps to reproduce (numbered list)
- Expected behaviour vs. actual behaviour
- Screenshots or screen recordings if applicable
- Relevant log output (redact any personal data)
- Device and OS information

### Feature Requests

For feature requests:
- Use the **Feature Request** issue template
- Describe the problem you're trying to solve (not just the solution)
- Explain how the feature benefits the target users (elderly / accessibility)
- Indicate if you're willing to implement it yourself

### Security Vulnerabilities

**Do not** file a public issue for security vulnerabilities. Please follow the process in [SECURITY.md](SECURITY.md).

---

## Development Workflow

We use a **fork-and-branch** workflow:

### Step 1: Fork the Repository

Click **Fork** on the GitHub repository page to create your own copy.

### Step 2: Clone Your Fork

```bash
git clone https://github.com/<your-username>/sahaayi.git
cd sahaayi
git remote add upstream https://github.com/your-org/sahaayi.git
```

### Step 3: Keep Your Fork Up to Date

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

### Step 4: Create a Branch

Create a new branch from `main` following the [branch naming conventions](#branch-naming-conventions):

```bash
git checkout -b feature/ocr-language-detection
```

### Step 5: Develop and Commit

Make your changes in small, logical increments. Follow the [commit message format](#commit-message-format).

```bash
git add .
git commit -m "feat(ocr): add automatic language detection for Malayalam/English"
```

### Step 6: Push and Open a Pull Request

```bash
git push origin feature/ocr-language-detection
```

Then open a Pull Request from your fork's branch to the `main` branch of the upstream repository. Fill in the PR template completely.

### Step 7: Respond to Review Feedback

Address all review comments. Push additional commits to your branch; do **not** force-push during active review unless requested.

### Step 8: Merge

Once approved and all checks pass, a maintainer will merge the PR (squash merge preferred for feature branches).

---

## Branch Naming Conventions

Branches must follow this format: `<type>/<short-description-in-kebab-case>`

| Prefix | Purpose | Example |
|---|---|---|
| `feature/` | New features or significant additions | `feature/medicine-reminder-ui` |
| `fix/` | Bug fixes | `fix/tts-crash-on-empty-string` |
| `docs/` | Documentation only changes | `docs/update-api-reference` |
| `refactor/` | Code refactoring (no behaviour change) | `refactor/ocr-service-abstraction` |
| `test/` | Adding or improving tests | `test/autofill-matching-unit-tests` |
| `chore/` | Maintenance tasks (deps, build config) | `chore/update-flutter-sdk` |
| `perf/` | Performance improvements | `perf/reduce-tts-latency` |
| `ci/` | CI/CD pipeline changes | `ci/add-flutter-lint-step` |

**Rules:**
- Use lowercase letters, numbers, and hyphens only.
- Keep descriptions concise but descriptive (3–5 words).
- One concern per branch; do not mix feature work with bug fixes.

---

## Commit Message Format

We follow the **Conventional Commits** specification (https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Types

| Type | When to Use |
|---|---|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation changes only |
| `style` | Formatting, whitespace (no logic change) |
| `refactor` | Code restructuring without feature/fix |
| `test` | Adding or modifying tests |
| `chore` | Dependency updates, build scripts |
| `perf` | Performance improvements |
| `ci` | CI/CD pipeline configuration |
| `revert` | Reverting a previous commit |

### Scopes

Use the component name as the scope:

| Scope | Description |
|---|---|
| `auth` | Authentication and authorisation |
| `ocr` | OCR document reading |
| `tts` | Text-to-speech |
| `asr` | Automatic speech recognition |
| `reminders` | Medicine reminders |
| `autofill` | Smart autofill |
| `fall-detection` | Fall detection |
| `profile` | User profile / personal memory |
| `transcription` | Audio transcription |
| `frontend` | Flutter UI (when not feature-specific) |
| `backend` | FastAPI backend (when not feature-specific) |
| `ai-engine` | AI microservice |
| `db` | Database / migrations |
| `deps` | Dependency updates |

### Examples

```bash
# Good commit messages
feat(ocr): extract and structure Malayalam Aadhaar card fields
fix(tts): prevent crash when input string contains only punctuation
docs(api): add response schema for /documents/{id}/extract endpoint
test(autofill): add unit tests for semantic field matching algorithm
chore(deps): upgrade fastapi from 0.100 to 0.104
refactor(profile): extract ProfileRepository from ProfileService
perf(asr): reduce IndicConformer cold start time by preloading model

# Bad commit messages (too vague or wrong format)
update stuff
Fixed bug
WIP
changes to ocr
```

### Body and Footer

- Use the body to explain **why** the change was made, not what (the diff shows what).
- Use `BREAKING CHANGE:` in the footer for breaking API changes.
- Reference issues with `Closes #123` or `Fixes #456`.

```bash
feat(reminders): add snooze functionality to medicine alerts

Elderly users frequently miss or dismiss alerts accidentally.
Snooze provides a 10-minute delay option via voice ("snooze cheyyuka")
or a large on-screen button, reducing missed doses.

Closes #42
```

---

## Pull Request Checklist

Before marking your PR ready for review, ensure the following:

### General
- [ ] PR title follows the conventional commits format (`type(scope): description`)
- [ ] PR description explains the motivation and what changed
- [ ] Related issue is linked (`Closes #<issue-number>`)
- [ ] No unrelated changes are included
- [ ] No debugging code, `print()` statements, or `TODO`s without tracking issues

### Code Quality
- [ ] Code is self-documenting; complex logic has inline comments
- [ ] All new functions and classes have docstrings (Python) or doc comments (Dart)
- [ ] No hardcoded secrets, API keys, or sensitive data
- [ ] Error cases are handled gracefully

### Testing
- [ ] New business logic is covered by unit tests
- [ ] New UI components have widget tests (Flutter)
- [ ] New API endpoints have integration tests
- [ ] All existing tests pass locally (`make test-backend`, `make test-frontend`)

### Accessibility
- [ ] New Flutter widgets have correct `Semantics` labels
- [ ] New UI elements meet minimum touch target size (48×48 dp)
- [ ] Text is readable at the project's minimum font scale
- [ ] Screen reader (TalkBack) compatibility verified if UI changed

### Documentation
- [ ] API changes are reflected in `docs/api-documentation.md`
- [ ] Database schema changes are reflected in `docs/database-schema.md`
- [ ] `CHANGELOG.md` entry added (if applicable)

### Backend Specific
- [ ] New database columns have a migration file
- [ ] New dependencies are justified and added to `requirements.txt`
- [ ] Environment variables are documented in `.env.example`

### Frontend Specific
- [ ] New packages are justified and added to `pubspec.yaml`
- [ ] App runs on minimum supported API (Android 8.0 / API 26)

---

## Code Review Process

### Reviewer Responsibilities

- Provide feedback within **48 hours** of being assigned.
- Use GitHub's suggestion feature for simple fixes.
- Be constructive and specific — explain the **why** behind requested changes.
- Distinguish between blocking concerns and optional suggestions (prefix optional suggestions with `nit:` or `optional:`).
- Approve only when you would be comfortable owning the code yourself.

### Author Responsibilities

- Respond to all comments before requesting re-review.
- Do not resolve comments you disagree with without discussion.
- Avoid force-pushing (rewriting history) during active review.
- Keep the PR focused; if review reveals unrelated issues, file separate issues rather than fixing them in the same PR.

### Approval Requirements

- At least **1 approval** from the other team member is required before merging.
- All automated checks (lint, tests, build) must pass.
- No unresolved review threads.

---

## Two-Member Team Coordination

As a two-person project, we maintain lightweight coordination rules to prevent conflicts and duplicated work:

### Communication

- **Daily sync**: A brief (async) message in the team channel at the start of each work session noting what you're working on.
- **Blocking issues**: Raise blockers immediately — do not wait for a sync. Use GitHub issue comments or direct messages.
- **Design decisions**: Any architectural decision affecting both frontend and backend must be discussed and agreed upon before implementation begins. Document decisions in `docs/decisions/` (Architecture Decision Records).

### Work Assignment

- Each feature or bug fix is tracked as a GitHub issue.
- Assign yourself to an issue before starting work.
- Do not start work on an unassigned issue without communicating first.

### Conflict Resolution

- If two team members disagree on an implementation approach, discuss in the PR or issue thread.
- If agreement cannot be reached within one day, escalate to a brief synchronous discussion.
- Document the outcome and reasoning in the PR or a decision record.

### Shared Ownership

- Both team members are responsible for the quality of the entire codebase.
- Code reviews are not optional, even from a small team.
- Either team member may merge their own PR only after approval from the other.

---

## Style Guides

- **Python (backend/ai-engine):** PEP 8, enforced by `ruff` and `black`. Type hints required on all public functions.
- **Dart (frontend):** Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style). `flutter_lints` package enforced.
- **Kotlin (Android native):** Follow [Android Kotlin Style Guide](https://developer.android.com/kotlin/style-guide).
- **SQL:** Lowercase keywords, snake_case identifiers, explicit column lists in queries.
- **YAML/JSON:** 2-space indentation, no trailing whitespace.

---

## Questions?

If you have questions not covered here, please open a [Discussion](https://github.com/your-org/sahaayi/discussions) or reach out to the maintainers via the contact information in the README.
