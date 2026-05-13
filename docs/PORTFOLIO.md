# RunK Portfolio Document

## 1. 프로젝트 개요

RunK는 러닝 기록을 저장하고 친구/피드로 공유하는 소셜 러닝 MVP입니다.  
개인 기록 관리에 머무르지 않고, 러닝을 친구와 이어지는 가벼운 소셜 경험으로 확장하는 것을 목표로 했습니다.

## 2. 문제 정의

러닝 앱은 개인 기록 측정에는 강하지만, 초보 러너나 혼자 달리는 사용자가 꾸준히 동기부여를 받기에는 부족한 경우가 많습니다. RunK는 러닝 기록을 피드와 친구 활동으로 연결해 작은 성취가 사회적 피드백으로 이어지도록 설계했습니다.

## 3. MVP 목표

핵심 제품 루프:

```text
회원가입 -> 로그인 -> 러닝 기록 저장 -> 홈/기록 확인 -> 피드 공유 -> 친구 활동 확인
```

MVP에서 검증한 범위:

- 회원가입/로그인
- JWT 세션 복원
- 러닝 기록 저장
- 내 기록 및 피드 조회
- 친구/채팅 UI 프로토타입
- 다크/라이트 테마 전환
- 보안 기본값과 입력 검증

## 4. 기술 스택

| 영역 | 기술 |
| --- | --- |
| Frontend | Flutter, Material 3 |
| Backend | FastAPI |
| Database | MySQL 8.0 |
| ORM | SQLAlchemy |
| Validation | Pydantic |
| Authentication | JWT, bcrypt |
| Local Infra | Docker Compose |
| Dev Tools | Android Studio, PowerShell, Flutter Test |

## 5. 아키텍처

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

Flutter 앱은 `ApiClient`를 통해 FastAPI REST API를 호출합니다. FastAPI는 Pydantic으로 요청을 검증하고 SQLAlchemy로 MySQL에 접근합니다.

## 6. 주요 기능

### 인증

- 이메일/비밀번호 로그인
- 회원가입
- 이메일/닉네임 중복 확인
- 비밀번호 정책 검증
- JWT 토큰 저장 및 세션 복원
- 로그아웃

### 러닝 기록

- 거리, 시간, 날짜, 메모 입력
- 페이스 자동 계산
- 미래 날짜 및 비정상 거리/시간 차단
- 내 러닝 기록 조회

### 홈

- 오늘의 러닝 요약
- 이번 주 거리/시간/페이스 요약
- 최근 러닝 카드
- 러닝 시작 버튼

### 친구/피드/기록

- 친구 목록 UI
- 채팅 목록 UI
- 글로벌 피드 조회
- 기록 통계 카드
- 주간 흐름 그래프 UI

### 설정

- 다크 모드/라이트 모드 전환
- 러닝 설정
- 공개 범위
- 보안/앱 정보

## 7. 데이터베이스 설계

### `users`

| 컬럼 | 설명 |
| --- | --- |
| `id` | 사용자 ID |
| `email` | 로그인 이메일 |
| `username` | 표시 이름 |
| `hashed_password` | bcrypt 해시 |
| `created_at` | 생성 시각 |

### `running_records`

| 컬럼 | 설명 |
| --- | --- |
| `id` | 러닝 기록 ID |
| `user_id` | 사용자 ID |
| `distance_km` | 거리 |
| `duration_seconds` | 시간 |
| `pace_seconds_per_km` | km당 페이스 |
| `run_date` | 러닝 날짜 |
| `memo` | 메모 |
| `created_at` | 생성 시각 |

## 8. 보안 설계

- 비밀번호는 bcrypt 해시로만 저장
- JWT secret 환경 변수화
- non-local 환경에서 기본 개발 secret 차단
- CORS origin 환경 변수화
- 보안 헤더 추가
- API 입력값 검증
- 피드 조회 limit 범위 제한

## 9. 개발 및 검증

| 항목 | 결과 |
| --- | --- |
| FastAPI 헬스 체크 | 통과 |
| 회원가입 API | 통과 |
| 로그인 API | 통과 |
| 러닝 기록 생성 API | 통과 |
| 피드 조회 API | 통과 |
| Flutter analyze | 통과 |
| Flutter widget test | 통과 |
| Flutter Windows debug build | 통과 |

검증 명령:

```powershell
cd frontend
dart format lib test
flutter analyze
flutter test
flutter build windows --debug
```

## 10. 프로젝트 의사결정

### MVP-first

친구 관계, 채팅, GPS 경로 저장은 실제 DB/API까지 확장하기 전 UI와 핵심 흐름을 먼저 구현했습니다.

### FastAPI + Pydantic

보안과 입력 검증을 명확히 표현하기 위해 FastAPI와 Pydantic을 사용했습니다.

### Docker Compose

개발 환경 재현성을 위해 MySQL을 Docker Compose로 실행합니다. 포트 충돌을 피하기 위해 호스트 포트는 `3307`을 사용합니다.

### Flutter 테마 구조

설정 화면에서 다크/라이트 모드를 전환할 수 있도록 앱 색상 토큰을 중앙화했습니다.

## 11. 현재 상태

MVP 기본 흐름과 포트폴리오 제출용 앱 구조는 완성 상태입니다.

남은 과제:

- 친구 관계 테이블/API 구현
- 피드 좋아요/댓글
- 실제 GPS 경로 저장
- Android Emulator 및 실기기 QA
- 배포 환경 구성

## 12. 회고

이번 프로젝트를 통해 단순 CRUD가 아니라 인증, 검증, 보안 기본값, UI 구조, 로컬 인프라, 문서화까지 이어지는 실제 개발 흐름을 경험했습니다. 특히 MVP 범위를 명확히 두고 단계적으로 확장하는 방식의 중요성을 확인했습니다.
