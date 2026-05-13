# GitHub Upload Guide

This guide is for submitting RunK as a portfolio project.

## Recommended Repository Setup

- Repository: `LEEDONGSOO1219/runk`
- Visibility: private during active development, public only after checking secrets
- Description: `Social running MVP built with Flutter, FastAPI, and MySQL.`
- Main portfolio document: `docs/PORTFOLIO.md`
- Korean portfolio package: `docs/portfolio-ko/`
- DOCX report: `deliverables/Runk_Portfolio_Report.docx`

## Do Not Upload

The following files must stay local:

- `backend/.env`
- `backend/.venv/`
- `backend/.deps/`
- `frontend/.dart_tool/`
- `frontend/build/`
- `.tmp_make_extract/`
- MySQL data volumes

These paths are ignored by `.gitignore`.

## Before Pushing

Run the validation commands from the project root:

```powershell
cd frontend
dart format lib test
flutter analyze
flutter test
flutter build windows --debug
```

For backend validation:

```powershell
docker compose up -d db
.\scripts\start-backend.ps1
.\scripts\smoke-backend.ps1
```

## Commit Flow

```powershell
git status
git add README.md docs deliverables backend frontend scripts .gitignore
git commit -m "chore: update portfolio materials"
git push origin main
```

## Sharing a Private Repository

1. Open the GitHub repository.
2. Go to `Settings`.
3. Go to `Collaborators`.
4. Invite the reviewer by GitHub username or email.
5. Send the repository link after the invite is accepted.

Private repository links show 404 unless the reviewer has access.

## Submission Checklist

- GitHub repository link is accessible to the reviewer
- `README.md` explains the project clearly
- `docs/PORTFOLIO.md` summarizes scope, architecture, security, and tests
- `docs/portfolio-ko/` contains formal Korean portfolio documents
- `deliverables/Runk_Portfolio_Report.docx` is regenerated from current content
- No secrets or local build artifacts are committed
