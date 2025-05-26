# 아블 플래너

**일상, 주간, 달력 플래너를 하나로 통합한 스마트한 계획 앱.**  
Flutter 기반으로 개발된 1인 개발 프로젝트이며, 기기 내 로컬 데이터를 활용해 서버 없이도 완전한 플래닝 경험을 제공합니다.

---

## 📌 주요 기능

- 일상 플래너: 상황 + 행동 중심의 기록
- 주간 플래너: 요일별 일정과 중요도 설정
- 달력 플래너: 날짜 기반 일정 메모 및 검색
- 종합 플래너: 모든 일정 요약 뷰
- 기록 저장: 하루가 바뀌면 자동으로 어제 일정 완료 여부 기록

---

## 🗂️ 폴더 구조 - Clean Architecture 기반

```
lib/
├── core/ # 공통 유틸, 테마, 상수, 공통 위젯
├── features/
│ ├── daily_planner/ # 일상 플래너 (상황 기반)
│ ├── weekly_planner/ # 주간 플래너
│ ├── calendar_planner/ # 달력 플래너
│ └── home_planner/ # 종합 플래너 (요약)
├── main.dart
└── routes/ # GoRouter 설정
```

---

## 🛠 상태관리

**[flutter_riverpod](https://riverpod.dev/)**  
- 전역 상태 및 비동기 로직 관리
- `StateNotifier`, `Notifier`, `FutureProvider` 등 다양하게 사용

---

## 📦 로컬 데이터 저장

**[Hive](https://docs.hivedb.dev/)** 기반 로컬 NoSQL 데이터베이스 사용  
- 할 일(Task), 기록 등 모든 데이터는 디바이스 내부에 저장
- 매일 자정 기준으로 어제 기록 자동 백업 (`RecordSaver`)

```dart
flutter pub run build_runner build --delete-conflicting-outputs
```

## ⚙️ CI/CD
GitHub Actions

- PR 또는 커밋 시 자동 빌드 및 테스트
- flutter test, flutter analyze, flutter build apk 자동 실행
---

## ✅ 테스트 전략
| 구분               | 대상        | 방식                       |
| ---------------- | --------- | ------------------------ |
| Unit Test        | 모델, 계산 로직 | `flutter_test`           |
| Widget Test      | UI 위젯     | `tester.pumpWidget(...)` |
| Integration Test | 전체 흐름     | `integration_test`       |

---

## 🔒 개인정보 처리방침
- 아블 플래너는 외부 서버나 광고 SDK를 사용하지 않으며, 모든 데이터는 로컬에 저장됩니다.
- 앱 내 앱 정보 > 개인정보 처리방침 보기에서 확인 가능
- HTML 파일로 제공 (assets/privacy_policy.html)

---

## 📜 라이선스
- 이 프로젝트는 CC BY-NC-ND 4.0 (저작자표시-비영리-변경금지) 라이선스를 따릅니다.
- 참고 및 학습 목적 사용은 허용
- 수정, 상업적 이용, 재배포는 금지
---
