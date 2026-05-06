# Runk Development Guide

이 문서는 런크를 회사 프로젝트처럼 재현 가능하게 실행하기 위한 개발 절차입니다.

## 역할 분리

- Flutter: 앱 화면, 사용자 입력, API 호출
- FastAPI: 인증, 러닝 기록, 피드 API
- MySQL: 사용자와 러닝 기록 저장
- Docker: 개발용 MySQL 실행
- Android Studio: Android SDK, Emulator, Flutter 앱 실행

## 로컬 실행 순서

1. DB 실행

```powershell
.\scripts\start-db.ps1
```

PowerShell 실행 정책으로 막히면 아래처럼 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-db.ps1
```

2. 백엔드 실행

```powershell
.\scripts\start-backend.ps1
```

3. 백엔드 검증

다른 PowerShell에서 실행합니다.

```powershell
.\scripts\smoke-backend.ps1
```

PowerShell 실행 정책으로 막히면 아래처럼 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-backend.ps1
```

4. Flutter 의존성 설치

```powershell
cd frontend
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## Android Emulator 실행

Android Emulator에서 PC의 백엔드 `127.0.0.1:8000`에 접근하려면 `10.0.2.2`를 사용합니다.

```powershell
cd frontend
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Chrome 또는 Windows desktop으로 실행할 때는 기본값 `http://localhost:8000`을 사용해도 됩니다.

## 현재 결정 사항

- MVP에서는 실시간 위치 공유를 제외합니다.
- 개발용 MySQL은 호스트 `3307` 포트를 사용합니다.
- `bcrypt==4.0.1`로 고정합니다. `passlib==1.7.4`와 최신 `bcrypt 5.x` 조합에서 회원가입 해싱 오류가 발생했습니다.
- Flutter 프로젝트는 Android Studio에서 열 수 있도록 `frontend/android` 플랫폼 파일을 포함합니다.
