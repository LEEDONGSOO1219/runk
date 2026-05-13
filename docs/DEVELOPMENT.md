# RunK Development Guide

RunK를 로컬에서 실행하고 검증하기 위한 개발 가이드입니다.

## 역할 분리

| 영역 | 책임 |
| --- | --- |
| Flutter | 화면, 입력 검증, API 호출, 세션 저장, 다크/라이트 테마 |
| FastAPI | 인증, 러닝 기록, 피드 API, 보안 헤더 |
| MySQL | 사용자와 러닝 기록 저장 |
| Docker | 개발용 MySQL 실행 |
| Scripts | 반복 실행 명령 자동화 |

## 로컬 실행 순서

### 1. DB 실행

```powershell
.\scripts\start-db.ps1
```

PowerShell 정책으로 막히면:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-db.ps1
```

### 2. 백엔드 실행

```powershell
.\scripts\start-backend.ps1
```

### 3. 백엔드 스모크 테스트

다른 PowerShell에서 실행합니다.

```powershell
.\scripts\smoke-backend.ps1
```

### 4. Flutter 검증

```powershell
cd frontend
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build windows --debug
```

## Android Emulator

Android Emulator에서는 PC의 `localhost`에 직접 접근할 수 없으므로 `10.0.2.2`를 사용합니다.

```powershell
cd frontend
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Windows desktop 또는 Chrome에서는 기본값 `http://localhost:8000`을 사용합니다.

## 보안 체크리스트

- `.env`는 커밋하지 않습니다.
- `JWT_SECRET_KEY`는 운영/배포 환경에서 반드시 교체합니다.
- `ENVIRONMENT != local`인 경우 기본 개발 JWT secret 사용을 차단합니다.
- CORS origin은 `CORS_ORIGINS`에 명시합니다.
- 비밀번호는 bcrypt 해시로만 저장합니다.
- 비밀번호 정책:
  - 8~16자
  - 공백 금지
  - 영문/숫자/특수문자 중 2가지 이상 조합
- 닉네임은 영문, 숫자, `.`, `_`, `-`만 허용합니다.
- 러닝 기록은 미래 날짜를 허용하지 않습니다.
- 피드 API는 `limit`을 1~100으로 제한합니다.

## 현재 개발 결정

- MySQL 개발 포트는 `3307`을 사용합니다.
- Flutter 앱은 `shared_preferences`로 JWT와 사용자 정보를 저장하고 앱 재시작 시 세션을 복원합니다.
- 친구/채팅은 현재 UI 단계이며, 실제 관계/메시지 API는 다음 단계에서 구현합니다.
- `bcrypt==4.0.1`을 사용합니다. `passlib==1.7.4`와 최신 `bcrypt 5.x` 조합에서 호환 문제가 발생할 수 있기 때문입니다.
- Windows desktop 빌드를 포트폴리오 시연용 기준으로 우선 검증합니다.

## 자주 쓰는 명령

```powershell
docker ps
docker stop runk_mysql
cd frontend
flutter run -d windows
flutter analyze
flutter test
flutter build windows --debug
```
