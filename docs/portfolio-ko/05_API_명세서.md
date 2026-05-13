# API 명세서

## Base URL

```text
http://localhost:8000
```

## API 목록

| Method | Endpoint | 설명 | Auth |
| --- | --- | --- | --- |
| GET | `/health` | 서버 상태 확인 | No |
| GET | `/auth/check-email` | 이메일 중복 확인 | No |
| GET | `/auth/check-username` | 닉네임 중복 확인 | No |
| POST | `/auth/signup` | 회원가입 | No |
| POST | `/auth/login` | 로그인 | No |
| GET | `/users/me` | 내 프로필 조회 | Yes |
| POST | `/running-records` | 러닝 기록 생성 | Yes |
| GET | `/running-records/me` | 내 러닝 기록 조회 | Yes |
| GET | `/feed` | 최신 피드 조회 | No |

## 회원가입

```http
POST /auth/signup
```

요청:

```json
{
  "email": "runner@example.com",
  "username": "runner01",
  "password": "password123"
}
```

응답:

```json
{
  "access_token": "...",
  "token_type": "bearer",
  "user": {
    "id": 1,
    "email": "runner@example.com",
    "username": "runner01",
    "created_at": "2026-05-13T00:00:00"
  }
}
```

## 로그인

```http
POST /auth/login
```

## 러닝 기록 생성

```http
POST /running-records
Authorization: Bearer <token>
```

요청:

```json
{
  "distance_km": 5.2,
  "duration_seconds": 2100,
  "run_date": "2026-05-13",
  "memo": "가볍게 달린 밤 러닝"
}
```

## 피드 조회

```http
GET /feed?limit=50
```

`limit`은 1~100 사이로 제한됩니다.
