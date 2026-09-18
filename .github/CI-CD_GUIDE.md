# TestThrive iOS CI/CD 가이드

## 📋 CI/CD 아키텍처 개요

TestThrive iOS 프로젝트에 적용할 수 있는 CI/CD 전략은 다음과 같습니다:

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub / GitLab                          │
│                   (소스 코드 저장소)                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│               CI/CD Pipeline (자동화)                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Lint   │──▶│  Build  │──▶│  Test   │──▶│ Archive │   │
│  │  & Format│ │(Debug)  │ │(Unit/UI) │ │(Release)│   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
    ┌────────┐  ┌──────────┐  ┌─────────────┐
    │ TestFlight│ App Store│ Slack 알림  │
    │(내부 테스팅)│  (배포)  │(빌드 상태)  │
    └────────┘  └──────────┘  └─────────────┘
```

## 🎯 권장 CI/CD 솔루션 비교

| 솔루션 | 비용 | 난이도 | 추천대상 |
|--------|------|--------|---------|
| **GitHub Actions** | 무료 (상한있음) | ⭐⭐ | GitHub 사용자, 중소 팀 |
| **GitLab CI/CD** | 무료 (상한있음) | ⭐⭐⭐ | GitLab 사용자, 엔터프라이즈 |
| **Fastlane + Jenkins** | 유료 (자체 서버) | ⭐⭐⭐⭐ | 높은 커스터마이징 필요 |
| **Xcode Cloud** | 유료 (Apple 정책) | ⭐ | Apple 에코시스템 선호자 |
| **Bitrise** | 유료 (클라우드) | ⭐⭐ | 모바일 전문, 편의성 중시 |

## 🏗️ 구현 계획 (3단계)

### Phase 1: 기본 CI 구성 (1주)
- ✅ GitHub Actions 또는 GitLab CI 설정
- ✅ 자동 Lint & Format 검사
- ✅ 자동 빌드 (Debug)
- ✅ 자동 Unit Test 실행

### Phase 2: 고급 CI + CD 구성 (2주)
- ✅ 자동 Archive (Release)
- ✅ TestFlight 배포 자동화
- ✅ Slack 알림 통합
- ✅ 코드 커버리지 리포트

### Phase 3: 모니터링 & 최적화 (진행형)
- ✅ 성능 메트릭 수집
- ✅ 빌드 시간 최적화
- ✅ 캐싱 전략 개선
- ✅ 자동 버전 관리

---

## 📱 우리 프로젝트의 CI/CD 추천 구성

### 선택 이유
**GitHub Actions** 추천:
1. ✅ 무료 (매월 2,000분의 무료 CI/CD 분량)
2. ✅ GitHub와 통합 (추가 연동 불필요)
3. ✅ macOS 러너 지원 (iOS 빌드 가능)
4. ✅ Secrets 관리 간편
5. ✅ 확장성 좋음 (Fastlane 연동 용이)

### 구성 요소
프로젝트에 추가할 파일:
```
TestThrive/
├── .github/
│   └── workflows/
│       ├── ci.yml                    # CI (Lint, Build, Test)
│       ├── cd-testflight.yml         # CD (TestFlight 배포)
│       └── cd-app-store.yml          # CD (App Store 배포)
├── fastlane/                         # Fastlane 자동화 스크립트
│   ├── Fastfile
│   ├── Appfile
│   └── certificates/
├── scripts/
│   ├── lint.sh                       # SwiftLint 실행
│   ├── test.sh                       # 테스트 실행
│   └── build.sh                      # 빌드 실행
└── .swiftlint.yml                    # SwiftLint 규칙
```

---

## 🚀 다음 단계

현재 아래의 파일들을 생성했습니다:

### 1️⃣ **CI 파이프라인** (`ci.yml`)
   - Pull Request 발생 시 자동 실행
   - Lint 검사
   - 빌드 검증
   - Unit Test 자동 실행

### 2️⃣ **CD 파이프라인 - TestFlight** (`cd-testflight.yml`)
   - main 브랜치 merge 시 자동 실행
   - Archive & Signing
   - TestFlight 배포
   - Slack 알림

### 3️⃣ **CD 파이프라인 - App Store** (`cd-app-store.yml`)
   - 태그 생성 시 자동 실행 (수동 트리거)
   - Archive & Signing
   - App Store Connect 배포

### 4️⃣ **Fastlane 구성**
   - 빌드/배포 자동화
   - 인증서 & 프로비저닝 프로파일 관리
   - 버전/빌드 번호 자동 업데이트

### 5️⃣ **지원 스크립트**
   - Lint 자동화
   - 빌드 자동화
   - 테스트 자동화

---

## 💡 사용 방법

1. **GitHub에 파일 push**
   ```bash
   git add .github/ fastlane/ scripts/ .swiftlint.yml
   git commit -m "chore: Add CI/CD pipeline"
   git push origin main
   ```

2. **GitHub Secrets 설정** (`.github/workflows/cd-testflight.yml`에서 필요)
   - `APPLE_ID`: Apple ID 이메일
   - `APPLE_ID_PASSWORD`: App-Specific Password
   - `FASTLANE_USER`: Fastlane 사용자
   - `FASTLANE_PASSWORD`: Fastlane 비밀번호
   - `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`: 앱 특화 비밀번호

3. **로컬에서 Fastlane 테스트**
   ```bash
   cd TestThrive
   fastlane setup_ci  # GitHub Actions 환경 설정
   fastlane test      # 테스트 실행
   fastlane build     # 빌드 실행
   ```

---

## 📊 CI/CD 흐름도

### Pull Request 시 (CI 실행)
```
PR 생성 → GitHub Actions 시작
  ├─ Lint 검사 ✓
  ├─ (옵션) Format 자동 수정
  ├─ Debug 빌드 ✓
  └─ Unit Test 실행 ✓
  → PR 승인 가능 또는 거절
```

### main 브랜치 merge 시 (CD 실행)
```
Push to main → GitHub Actions 시작
  ├─ CI 파이프라인 실행 (위 참고)
  ├─ Archive (Release 빌드)
  ├─ 서명 & 프로비저닝
  └─ TestFlight 배포
  → Slack 알림 (성공/실패)
```

### 태그 생성 시 (App Store 배포)
```
git tag v1.0.0 → Push
  → GitHub Actions 시작
  ├─ CI 파이프라인 실행
  ├─ Archive (Release 빌드)
  └─ App Store Connect 배포
  → Slack 알림 (성공/실패)
```

---

## ⚙️ 설정 후 체크리스트

- [ ] `.github/workflows/` 폴더 생성 및 파일 추가
- [ ] `fastlane/` 폴더 생성 및 구성
- [ ] `scripts/` 폴더 생성 및 스크립트 추가
- [ ] GitHub Secrets 설정
- [ ] SwiftLint 설치 (로컬): `brew install swiftlint`
- [ ] Fastlane 설치 (로컬): `sudo gem install fastlane -NV`
- [ ] 첫 번째 CI 테스트 실행
- [ ] 빌드 로그 검토 및 디버깅

---

## 🔧 로컬 개발 워크플로우

```bash
# 1. 기능 브랜치 생성
git checkout -b feature/my-feature

# 2. 개발 & 커밋
git add .
git commit -m "feat: add new feature"

# 3. PR 생성
git push origin feature/my-feature
# → GitHub에서 PR 생성 (CI 자동 실행)

# 4. PR 승인 & merge
# → CD 시작 (TestFlight 배포)

# 5. 릴리스 태그 생성
git tag v1.0.1
git push origin v1.0.1
# → CD 시작 (App Store 배포)
```

---

## 📚 참고 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Fastlane 공식 문서](https://docs.fastlane.tools)
- [SwiftLint 공식](https://github.com/realm/SwiftLint)
- [Apple App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

---

## 🎓 다음 질문?

1. 어떤 CI/CD 솔루션을 선택하시겠어요? (GitHub Actions 추천)
2. 자동 배포 수준은? (TestFlight만 vs. 전체 자동화)
3. Slack 알림 연동을 원하시나요?
4. 자동 버전 관리를 원하시나요?

앞으로 구체적인 파일들을 생성하겠습니다!
