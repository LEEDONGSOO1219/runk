# RunK Architecture

## 전체 구조

```text
Flutter App
  - screens
  - widgets
  - services/api_client.dart
  - local token storage
        |
        | REST API
        v
FastAPI
  - auth
  - running records
  - feed
  - security middleware
        |
        | SQLAlchemy
        v
MySQL
  - users
  - running_records
```

## 백엔드

FastAPI 진입점은 `backend/app/main.py`입니다.

| 파일 | 역할 |
| --- | --- |
| `main.py` | API 라우팅, CORS, 보안 헤더 |
| `schemas.py` | Pydantic 요청/응답 모델 |
| `models.py` | SQLAlchemy 모델 |
| `dependencies.py` | JWT 인증 의존성 |
| `core/security.py` | 비밀번호 해싱, JWT 발급/검증 |
| `core/config.py` | 환경 변수 설정 |
| `db.py` | DB 엔진/세션 |

현재 MVP는 개발 속도를 위해 앱 시작 시 `Base.metadata.create_all()`로 테이블을 생성합니다. 실제 운영 단계에서는 Alembic 마이그레이션으로 전환하는 것이 적절합니다.

## 데이터 모델

### users

- 이메일과 닉네임은 unique index를 가집니다.
- 비밀번호는 `hashed_password`에 bcrypt 해시로 저장합니다.
- 러닝 기록과 1:N 관계를 가집니다.

### running_records

- 사용자별 러닝 기록을 저장합니다.
- 거리와 시간으로 페이스를 계산해 저장합니다.
- 피드 조회 시 최신 생성순으로 정렬합니다.

## 프론트엔드

Flutter 앱은 탭 기반 구조입니다.

| 화면 | 역할 |
| --- | --- |
| `splash_screen.dart` | 앱 시작 로딩 |
| `auth_screen.dart` | 로그인/회원가입 |
| `main_shell.dart` | 하단 탭 네비게이션 |
| `home_screen.dart` | 오늘/주간 러닝 요약 |
| `friends_screen.dart` | 친구 목록/채팅 UI |
| `feed_screen.dart` | 러닝 피드 |
| `records_screen.dart` | 기록 통계/히스토리 |
| `settings_screen.dart` | 다크모드, 러닝 설정, 계정 |
| `record_form_screen.dart` | 러닝 기록 입력 |

공통 UI는 `widgets/`에 분리했습니다.

- `app_cards.dart`
- `running_record_card.dart`
- `auth_widgets.dart`
- `settings_widgets.dart`

## 테마 구조

앱은 `AppColors.configure(dark: bool)`를 통해 다크/라이트 색상 토큰을 전환합니다. 설정 화면에서 `다크 모드` 스위치를 변경하면 `MaterialApp`이 다시 빌드되며 전체 화면 색상이 변경됩니다.

## 보안 흐름

```text
회원가입/로그인
    |
    v
JWT access token 발급
    |
    v
Flutter shared_preferences 저장
    |
    v
인증 API 호출 시 Authorization: Bearer <token>
```

## 향후 확장

| 기능 | 설계 방향 |
| --- | --- |
| 친구 관계 | `friendships` 테이블 추가 |
| 채팅 | 메시지 테이블 또는 외부 메시징 서비스 연동 |
| GPS 경로 | `running_routes`, `route_points` 테이블 추가 |
| 피드 반응 | likes/comments 테이블 추가 |
| 배포 | 환경별 `.env`, HTTPS, DB migration |
