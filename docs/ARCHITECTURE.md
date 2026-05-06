# Runk Architecture

## MVP Scope

런크 MVP는 러닝 기록 기반 소셜 네트워크의 가장 작은 동작 단위를 제공합니다.

- 회원가입 / 로그인
- 내 프로필 조회
- 러닝 기록 저장
- 내 러닝 기록 조회
- 최신 피드 조회

## Backend

FastAPI 앱은 `backend/app/main.py`에서 시작합니다.

- `models.py`: SQLAlchemy 모델
- `schemas.py`: 요청/응답 DTO
- `dependencies.py`: JWT 인증 의존성
- `core/security.py`: 비밀번호 해싱, JWT 발급
- `db.py`: DB 엔진과 세션

현재는 MVP 속도를 위해 앱 시작 시 `Base.metadata.create_all()`로 테이블을 생성합니다. 운영 단계에서는 Alembic 마이그레이션으로 교체하는 것이 좋습니다.

## Database

현재 테이블:

- `users`
- `running_records`

다음 단계 후보:

- `friendships`
- `ranking_snapshots`
- `running_routes`
- `route_points`

## Frontend

Flutter 앱은 단순 상태 기반으로 구성합니다.

- `screens/auth_screen.dart`: 회원가입/로그인
- `screens/feed_screen.dart`: 최신 러닝 피드
- `screens/record_form_screen.dart`: 러닝 기록 저장
- `screens/profile_screen.dart`: 내 프로필
- `services/api_client.dart`: REST API 클라이언트

MVP에서는 복잡한 상태관리 라이브러리를 도입하지 않습니다. 친구, 랭킹, GPS 경로가 들어가는 시점에 Riverpod 같은 상태관리 도입을 검토합니다.
