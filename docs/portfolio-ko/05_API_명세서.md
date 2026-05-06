# API 명세서

## Base URL

로컬 개발환경:

```text
http://127.0.0.1:8000
```

Android Emulator:

```text
http://10.0.2.2:8000
```

## API 목록

| Method | Endpoint | 설명 | 인증 |
| --- | --- | --- | --- |
| GET | `/health` | 서버 상태 확인 | 불필요 |
| POST | `/auth/signup` | 회원가입 | 불필요 |
| POST | `/auth/login` | 로그인 | 불필요 |
| GET | `/users/me` | 내 프로필 조회 | 필요 |
| POST | `/running-records` | 러닝 기록 저장 | 필요 |
| GET | `/running-records/me` | 내 러닝 기록 조회 | 필요 |
| GET | `/feed` | 최신 피드 조회 | 불필요 |

## 1. Health Check

### Request

```http
GET /health
```

### Response

```json
{
  "status": "ok"
}
```

## 2. 회원가입

### Request

```http
POST /auth/signup
Content-Type: application/json
```

```json
{
  "email": "runner@example.com",
  "username": "runner01",
  "password": "password123"
}
```

### Response

```json
{
  "access_token": "jwt-token",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "runner@example.com",
    "username": "runner01",
    "created_at": "2026-05-06T11:43:03"
  }
}
```

## 3. 로그인

### Request

```http
POST /auth/login
Content-Type: application/json
```

```json
{
  "email": "runner@example.com",
  "password": "password123"
}
```

### Response

```json
{
  "access_token": "jwt-token",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "runner@example.com",
    "username": "runner01",
    "created_at": "2026-05-06T11:43:03"
  }
}
```

## 4. 내 프로필 조회

### Request

```http
GET /users/me
Authorization: Bearer jwt-token
```

### Response

```json
{
  "id": 1,
  "email": "runner@example.com",
  "username": "runner01",
  "created_at": "2026-05-06T11:43:03"
}
```

## 5. 러닝 기록 저장

### Request

```http
POST /running-records
Authorization: Bearer jwt-token
Content-Type: application/json
```

```json
{
  "distance_km": 5.0,
  "duration_seconds": 1800,
  "run_date": "2026-05-06",
  "memo": "5km easy run"
}
```

### Response

```json
{
  "id": 1,
  "user_id": 1,
  "username": "runner01",
  "distance_km": 5.0,
  "duration_seconds": 1800,
  "pace_seconds_per_km": 360,
  "run_date": "2026-05-06",
  "memo": "5km easy run",
  "created_at": "2026-05-06T11:43:03"
}
```

## 6. 내 러닝 기록 조회

### Request

```http
GET /running-records/me
Authorization: Bearer jwt-token
```

### Response

```json
[
  {
    "id": 1,
    "user_id": 1,
    "username": "runner01",
    "distance_km": 5.0,
    "duration_seconds": 1800,
    "pace_seconds_per_km": 360,
    "run_date": "2026-05-06",
    "memo": "5km easy run",
    "created_at": "2026-05-06T11:43:03"
  }
]
```

## 7. 피드 조회

### Request

```http
GET /feed
```

### Response

```json
[
  {
    "id": 1,
    "user_id": 1,
    "username": "runner01",
    "distance_km": 5.0,
    "duration_seconds": 1800,
    "pace_seconds_per_km": 360,
    "run_date": "2026-05-06",
    "memo": "5km easy run",
    "created_at": "2026-05-06T11:43:03"
  }
]
```

