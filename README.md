# Runk

런크는 러닝 기록 기반 소셜 네트워크 서비스 MVP입니다.

## Tech Stack

- Frontend: Flutter
- Backend: FastAPI
- Database: MySQL
- Local Infra: Docker Compose

## Project Structure

```text
.
├── backend/              # FastAPI API server
├── frontend/             # Flutter app
├── docs/                 # Architecture and development docs
├── scripts/              # Local development scripts
├── docker-compose.yml    # MySQL container
└── README.md
```

## Quick Start

1. Start MySQL.

```powershell
.\scripts\start-db.ps1
```

2. Start the backend.

```powershell
.\scripts\start-backend.ps1
```

3. Check backend API.

```powershell
.\scripts\smoke-backend.ps1
```

4. Run Flutter checks.

```powershell
cd frontend
flutter pub get
dart format lib test
flutter analyze
flutter test
```

If PowerShell blocks local scripts, run them with:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-backend.ps1
```

## Android Studio

Open the `frontend` folder in Android Studio.

For Android Emulator, use this run argument so the app can reach the backend running on the PC:

```text
--dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For Chrome or Windows desktop, the default API URL is:

```text
http://localhost:8000
```

## API

| Method | Path | Description | Auth |
| --- | --- | --- | --- |
| GET | `/health` | Health check | No |
| POST | `/auth/signup` | Sign up | No |
| POST | `/auth/login` | Login | No |
| GET | `/users/me` | My profile | Yes |
| POST | `/running-records` | Create running record | Yes |
| GET | `/running-records/me` | My running records | Yes |
| GET | `/feed` | Latest feed | No |

## Docs

- [Portfolio Document](docs/PORTFOLIO.md)
- [Development Guide](docs/DEVELOPMENT.md)
- [Architecture](docs/ARCHITECTURE.md)

## Current MVP Scope

Included:

- Sign up / login
- Running record save
- Simple feed
- Profile

Excluded for now:

- Friends
- Ranking
- GPS route storage
- AI feed
- Course recommendation
- Realtime location sharing
