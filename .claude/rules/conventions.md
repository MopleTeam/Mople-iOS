# 프로젝트 공통 컨벤션

> 이 규칙은 경로 필터 없이 항상 적용된다.

## 신규 vs 기존 코드 정책
- **신규 화면**: SwiftUI + async/await 기반으로 작성
- **기존 화면 수정/기능 추가**: 기존 방식(UIKit + RxSwift + ReactorKit) 유지
- **판단 기준**: 해당 파일/화면이 이미 존재하면 "기존", 새로 만드는 화면이면 "신규"
- **향후 방향**: 전체 SwiftUI + async/await 전환 예정 (리팩토링 로드맵 Phase 3, 5)

## 네이밍 규칙
- 클래스/구조체: UpperCamelCase
- 프로퍼티/메서드: lowerCamelCase
- 프로토콜: 동사형 또는 역할명 (예: `FetchNotifyList`, `MeetRepo`)
- 구현체: `Default{Protocol}` 또는 `{Protocol}UseCase`
- Mock: `Mock{Protocol}UseCase`

## LifeCycle 로깅
- `LifeCycleLoggable` 프로토콜을 주요 객체(Reactor, Repository, DIContainer 등)에 적용
- init/deinit 시점에 로그 출력으로 메모리 관리 추적

## 비동기 처리 규칙
### 기존 코드 (UIKit + RxSwift)
- 비동기 단발성 작업: `Single<T>`
- 스트림: `Observable<T>`
- UI 바인딩: `Driver`, `Singal` 사용 권장
- 구독 해제: `DisposeBag` 필수
- 스레드: UI 작업은 `MainScheduler.instance`

### 신규 코드 (SwiftUI + async/await)
- 비동기 작업: `async throws` 함수
- 스트림: `AsyncSequence`, `AsyncStream`
- 상태 관리: `@Observable`, `@State`, `@Binding`
- 에러 처리: `do-catch`, typed throws
- 동시성: `Task`, `TaskGroup`, `actor`

## 메모리 누수 관리
- 작업 완료 후 메모리 누수 여부를 반드시 점검한다
- 코드 작성 시 누수 방지 패턴을 항상 적용:
  - RxSwift 클로저: `[weak self]` 캡처 리스트 필수
  - `subscribe(with: self)` 패턴 사용 권장 (`subscribe(onNext:)` 대신)
  - delegate: `weak` 선언
  - 클로저 프로퍼티: `nil` 처리 또는 `[weak self]`
  - Timer, NotificationCenter: deinit에서 해제
  - async/await Task: `[weak self]` 또는 ViewModel이 해제될 때 Task cancel
- `LifeCycleLoggable`로 init/deinit 로그 확인 — deinit이 호출되지 않으면 누수 의심
- 순환 참조 위험 지점: Reactor ↔ ViewController, Coordinator ↔ ViewController, 클로저 캡처

## 에러 처리
- 레이어별 커스텀 에러 enum 정의
- Network: `DataRequestError`
- Presentation: 화면별 에러 enum

## 조건부 컴파일
- `#if DEV` — Mople Dev 타겟 전용 (TestFlight 포함)
- `#if DEBUG` — Debug 빌드 전용 (모든 타겟)
- `#if DEV && DEBUG` — 로컬 실행 전용 (TestFlight에서 미노출)
- `#else` — 프로덕션 코드
- **주의**: TestFlight에 노출되면 안 되는 기능(Mock 토글 등)은 반드시 `#if DEV && DEBUG` 사용

## 다크/라이트 모드 대응
- **border 색상**: `layer.makeLine()` 대신 `setDynamicBorder(width:color:)` 사용
  - `CGColor`는 정적 값이라 모드 전환 시 업데이트 안 됨
  - `setDynamicBorder`는 `registerForTraitChanges`로 자동 업데이트
- **shadow 색상**: `UIColor.black` 고정이라 모드 대응 불필요
- **외부 SDK 이미지** (네이버 지도 마커 등): `imageAsset?.image(with: traitCollection)`로 현재 모드 이미지 resolve
- **네이버 지도**: `traitCollectionDidChange`에서 `isNightModeEnabled` 토글

## 주석
- 주요 기능에 한국어 주석 추가
- 코드의 역할과 의도를 간결하게 설명
