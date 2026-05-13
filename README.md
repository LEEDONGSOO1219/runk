# RunK

RunK는 러닝 기록을 저장하고 친구/피드로 공유하는 소셜 러닝 MVP입니다.  
개인 러닝 기록, 피드, 친구 화면, 기록 통계, 다크/라이트 테마 전환, JWT 기반 인증 흐름을 하나의 앱 경험으로 연결했습니다.

## 핵심 포인트

- Flutter 기반 모바일/Windows 데스크톱 앱
- FastAPI + MySQL 기반 REST API
- JWT 로그인, bcrypt 비밀번호 해싱, 세션 복원
- 이메일/닉네임 중복 확인 API
- 러닝 기록 저장, 내 기록 조회, 피드 조회
- 친구/채팅 UI, 기록 통계, 설정 화면
- 설정에서 다크 모드/라이트 모드 전환
- 개발용 Docker Compose, PowerShell 실행 스크립트, 포트폴리오 문서 포함

## 기술 스택

| 영역 | 기술 |
| --- | --- |
| Frontend | Flutter, Material 3 |
| Backend | FastAPI, Pydantic |
| Database | MySQL 8.0 |
| ORM | SQLAlchemy |
| Auth | JWT, bcrypt |
| Local Infra | Docker Compose |
| Tooling | Android Studio, PowerShell, Flutter Test |

## 프로젝트 구조

```text
.
|-- backend/              # FastAPI API 서버
|-- frontend/             # Flutter 앱
|-- docs/                 # 개발/아키텍처/포트폴리오 문서
|-- docs/portfolio-ko/    # 제출용 한글 산출물
|-- scripts/              # 로컬 실행 스크립트
|-- deliverables/         # 제출 파일 산출물
|-- docker-compose.yml    # MySQL 개발 컨테이너
`-- README.md
```

## 빠른 실행

### 1. MySQL 실행

```powershell
.\scripts\start-db.ps1
```

### 2. 백엔드 실행

```powershell
.\scripts\start-backend.ps1
```

### 3. 백엔드 스모크 테스트

```powershell
.\scripts\smoke-backend.ps1
```

### 4. Flutter 실행 및 검증

```powershell
cd frontend
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build windows --debug
```

Windows 데스크톱/Chrome 실행 시 기본 API 주소는 `http://localhost:8000`입니다.

Android Emulator에서 PC의 백엔드에 접근하려면 다음 값을 사용합니다.

```powershell
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## API 요약

| Method | Path | 설명 | Auth |
| --- | --- | --- | --- |
| GET | `/health` | 헬스 체크 | No |
| GET | `/auth/check-email` | 이메일 중복 확인 | No |
| GET | `/auth/check-username` | 닉네임 중복 확인 | No |
| POST | `/auth/signup` | 회원가입 | No |
| POST | `/auth/login` | 로그인 | No |
| GET | `/users/me` | 내 프로필 조회 | Yes |
| POST | `/running-records` | 러닝 기록 생성 | Yes |
| GET | `/running-records/me` | 내 러닝 기록 조회 | Yes |
| GET | `/feed?limit=50` | 최신 피드 조회 | No |

## 보안 고려 사항

- 비밀번호는 평문 저장 없이 bcrypt 해시만 저장합니다.
- JWT secret은 환경 변수로 관리하고, non-local 환경에서는 기본 개발 secret 사용을 차단합니다.
- CORS 허용 origin은 `CORS_ORIGINS`로 명시합니다.
- 보안 헤더를 미들웨어에서 추가합니다.
  - `X-Content-Type-Options`
  - `X-Frame-Options`
  - `Referrer-Policy`
  - `Permissions-Policy`
- Pydantic으로 입력값을 검증합니다.
  - 비밀번호 8~16자, 공백 금지, 영문/숫자/특수문자 중 2종 이상
  - 닉네임 형식 제한
  - 미래 날짜 러닝 기록 차단
  - 러닝 거리/시간 상한 제한
  - 피드 조회 limit 범위 제한

## 현재 MVP 범위

구현 완료:

- 회원가입/로그인
- 세션 복원 및 로그아웃
- 러닝 기록 저장
- 내 기록 및 피드 조회
- 홈/친구/피드/기록/설정 탭 구조
- 친구 목록/채팅 UI
- 다크/라이트 테마 전환
- Windows 디버그 빌드
- 개발/포트폴리오 문서

다음 단계:

- 실제 친구 관계 DB/API
- 채팅 API 또는 외부 메시징 연동
- GPS 경로 저장
- 피드 좋아요/댓글
- Android Emulator 실기기 검증
- 배포 환경 구성

## 문서

- [포트폴리오 문서](docs/PORTFOLIO.md)
- [한글 제출 문서 목차](docs/portfolio-ko/00_포트폴리오_목차.md)
- [개발 가이드](docs/DEVELOPMENT.md)
- [아키텍처](docs/ARCHITECTURE.md)
- [GitHub 업로드 가이드](docs/GITHUB_UPLOAD.md)
