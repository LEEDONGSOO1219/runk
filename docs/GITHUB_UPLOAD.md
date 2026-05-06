# GitHub Upload Guide

## Visibility Strategy

GitHub private repositories cannot be viewed by link alone.

If the repository is private, reviewers must be added as collaborators or organization members. A private repository link only works for people who have permission.

Recommended portfolio options:

1. Private repository + invite reviewers as collaborators.
2. Public repository with no secrets and no sensitive data.
3. Private repository for source code + public portfolio summary page.

For this project, option 1 is recommended while the app is still in active development.

## What Must Not Be Uploaded

These files should stay local:

- `backend/.env`
- `backend/.venv/`
- `backend/.deps/`
- `frontend/.dart_tool/`
- `frontend/build/`
- MySQL data volumes

The repository already ignores these files.

## Recommended Repository Settings

Repository name:

```text
runk
```

Visibility:

```text
Private
```

Suggested description:

```text
Running social network MVP built with Flutter, FastAPI, and MySQL.
```

## Local Git Flow

```powershell
git status
git add .
git commit -m "Initial Runk MVP scaffold"
git branch -M main
git remote add origin https://github.com/<your-github-username>/runk.git
git push -u origin main
```

## Sharing a Private Repository

1. Open the GitHub repository.
2. Go to `Settings`.
3. Go to `Collaborators`.
4. Invite the reviewer by GitHub username or email.
5. Send the repository link after the invite is accepted.

Without collaborator access, a private repository link will show a 404 or permission error.

## Portfolio Submission Link

Use this file as the main portfolio document:

```text
docs/PORTFOLIO.md
```

If the repository is private, include both:

- GitHub repository link
- Reviewer GitHub account invited as collaborator
