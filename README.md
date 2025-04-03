# 아블 플래너

**데일리, 위클리, 캘린더 플래너를 하나로 모은 스마트한 계획 앱.**  
Flutter로 개발된 오픈소스 플래너 앱이며, 1인 개발 프로젝트입니다.

## 설계 단계

### 🗂️ 폴더 구조 - Clean Architecture 기반
```
lib/
├── core/                    # 공통 유틸, 테마, 상수, 공통 위젯
├── features/
│   ├── daily_planner/       # 일상 플래너 (상황 기반)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── weekly_planner/      # 요일 플래너
│   ├── calendar_planner/    # 캘린더 플래너
│   └── home_planner/        # 종합 플래너 (요약)
├── main.dart
├── routes/                  # GoRouter 설정
└── di/                      # 의존성 주입
```

## 🛠 상태관리 방식
**[flutter_riverpod](https://riverpod.dev/)** 사용  
- 전역 상태 관리 및 의존성 주입에 용이
- `StateNotifier` / `Notifier`: 간단한 UI 상태
- `AsyncNotifier`, `FutureProvider`: 비동기 로직 처리

## ⚙️ CI/CD 파이프라인 적용
**[GitHub Actions](https://github.com/JeongHyeon-Jo/abeul_planner/blob/master/.github/workflows/flutter_ci.yml)**  
- PR/커밋 시 자동 빌드 & 테스트 실행  
- `flutter test`, `flutter analyze`, `flutter build apk` 자동 실행  
- 오류 없이 통과되면 APK 생성까지 자동화

## ✅ 테스트 전략
| 구분 | 대상 | 방식 |
|------|------|------|
| Unit Test | 모델, 계산 로직 | `flutter_test` |
| Widget Test | UI 컴포넌트 | `tester.pumpWidget(...)` |
| Integration Test | 시나리오 전반 | `integration_test` 패키지 |



