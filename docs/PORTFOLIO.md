# Runk Portfolio Document

## 1. Project Overview

Runk is a running social network MVP where users can sign up, save running records, and view recent running activity in a simple feed.

The project was built as a solo-developer MVP. The first milestone focuses on a working end-to-end flow rather than adding many social features too early.

## 2. Problem Statement

Many running apps are strong at personal tracking, but beginner or solo runners often need social motivation to keep running consistently.

Runk turns running records into shareable feed items so that running activity can become a lightweight social experience.

## 3. MVP Goal

The MVP goal is to validate the core product loop:

```text
Sign up -> Log in -> Save running record -> View feed -> View profile
```

Included in Phase 1:

- Sign up and login
- Save running records
- Simple feed
- Basic profile

Excluded from Phase 1:

- Friend system
- Ranking
- GPS route storage
- AI feed
- Course recommendation
- Realtime location sharing

## 4. Tech Stack

| Area | Technology |
| --- | --- |
| Frontend | Flutter |
| Backend | FastAPI |
| Database | MySQL |
| ORM | SQLAlchemy |
| Authentication | JWT, bcrypt password hashing |
| Local Infra | Docker Compose |
| Development Tools | Android Studio, PowerShell scripts |

## 5. Architecture

```text
Flutter App
    |
    | REST API
    v
FastAPI Backend
    |
    | SQLAlchemy ORM
    v
MySQL Database
```

The backend exposes REST APIs. The Flutter app calls those APIs through a small API client. MySQL stores users and running records.

## 6. Main Features

### Authentication

Users can sign up with email, username, and password. Passwords are hashed before storage. Login returns a JWT access token.

Implemented APIs:

- `POST /auth/signup`
- `POST /auth/login`
- `GET /users/me`

### Running Records

Users can save a running record with distance, duration, date, and memo. The backend calculates pace automatically.

Implemented APIs:

- `POST /running-records`
- `GET /running-records/me`

### Feed

The feed returns the latest running records. For the MVP, the feed is a simple global list.

Implemented API:

- `GET /feed`

### Profile

The Flutter app includes a basic profile screen showing the authenticated user's account information.

## 7. Database Design

### `users`

| Column | Description |
| --- | --- |
| `id` | User ID |
| `email` | Login email |
| `username` | Display name |
| `hashed_password` | Hashed password |
| `created_at` | Created timestamp |

### `running_records`

| Column | Description |
| --- | --- |
| `id` | Running record ID |
| `user_id` | Owner user ID |
| `distance_km` | Distance in kilometers |
| `duration_seconds` | Running duration in seconds |
| `pace_seconds_per_km` | Pace per kilometer |
| `run_date` | Running date |
| `memo` | Optional memo |
| `created_at` | Created timestamp |

## 8. Project Structure

```text
.
├── backend/
│   ├── app/
│   │   ├── core/
│   │   ├── db.py
│   │   ├── dependencies.py
│   │   ├── main.py
│   │   ├── models.py
│   │   └── schemas.py
│   └── requirements.txt
├── frontend/
│   ├── android/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── test/
├── docs/
├── scripts/
└── docker-compose.yml
```

## 9. Development Workflow

The project includes scripts to make local development reproducible.

| Script | Purpose |
| --- | --- |
| `scripts/start-db.ps1` | Start MySQL with Docker Compose |
| `scripts/start-backend.ps1` | Prepare and run the FastAPI backend |
| `scripts/smoke-backend.ps1` | Test signup, record creation, and feed retrieval |

Recommended local workflow:

```powershell
.\scripts\start-db.ps1
.\scripts\start-backend.ps1
.\scripts\smoke-backend.ps1
```

If PowerShell blocks scripts:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-backend.ps1
```

Flutter checks:

```powershell
cd frontend
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## 10. Android Studio Setup

The `frontend/android` project files are generated, so the `frontend` folder can be opened directly in Android Studio.

For Android Emulator, use this Dart define:

```text
--dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Reason: Android Emulator cannot access the host PC backend through `localhost`.

For Chrome or Windows desktop builds, the default API URL is:

```text
http://localhost:8000
```

## 11. Validation Result

Current validation status:

| Check | Result |
| --- | --- |
| MySQL Docker container | Passed |
| Backend health check | Passed |
| Signup API | Passed |
| Running record API | Passed |
| Feed API | Passed |
| Flutter analyze | Passed |
| Flutter widget test | Passed |

Backend smoke test result verified:

```text
health: ok
signup: passed
create running record: passed
read feed: passed
```

## 12. Technical Decisions

### MVP-first scope

The project intentionally avoids adding friends, ranking, GPS routes, and AI recommendations in the first version. The priority is to validate the smallest complete product loop.

### FastAPI and SQLAlchemy

FastAPI provides clear REST API implementation with Pydantic schemas. SQLAlchemy keeps the database layer flexible for future social and ranking features.

### Docker Compose for MySQL

Docker Compose reduces local database setup friction. The host port is set to `3307` to avoid conflicts with existing MySQL installations on port `3306`.

### Configurable API base URL

Flutter reads `API_BASE_URL` through `--dart-define`, which makes the app work across Chrome, Windows desktop, and Android Emulator.

### bcrypt version pinning

`bcrypt==4.0.1` is pinned because `passlib==1.7.4` had a password hashing issue with newer `bcrypt 5.x`.

## 13. Current Status

Phase 1 MVP foundation is complete.

Completed:

- Backend REST APIs
- MySQL Docker setup
- Flutter screen structure
- Android Studio project structure
- Local development scripts
- Architecture and development documentation
- Backend smoke test
- Flutter static analysis and widget test

Remaining:

- Run and verify the app on Android Emulator
- Improve UI polish
- Add richer validation and error messages
- Expand test coverage
- Prepare deployment environment

## 14. Roadmap

### Phase 1: MVP

- Sign up / login
- Running record save
- Feed
- Profile

### Phase 2: Social

- Friend system
- Weekly distance ranking
- Basic user running stats

### Phase 3: Route and Recommendation

- GPS route coordinate storage
- Rule-based AI feed
- Running course recommendation

## 15. Key Learnings

- A useful MVP needs a complete product loop before advanced features.
- Mobile apps need environment-specific backend URLs, especially for Android Emulator.
- Docker and scripts make onboarding more predictable.
- Smoke tests are valuable for catching real API and dependency issues early.
