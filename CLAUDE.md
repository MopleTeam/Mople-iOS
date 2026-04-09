# Mople 프로젝트 규칙

## 프로젝트 개요
- iOS 모임 관리 앱 (개인 프로젝트, 업무보고 제외)
- iOS 1인 개발 / 백엔드·디자인은 별도 팀원
- 향후 iOS 인원 추가 예정 → 팀 합류 대비 환경 구축 중

## 현재 기술 스택
- **아키텍처**: Clean Architecture + MVVM + Coordinator + ReactorKit
- **비동기**: RxSwift 6.7.1 (전체 파일의 48.6%)
- **UI**: UIKit 중심 (96.4%) + SwiftUI 일부 (3.6%)
- **네트워크**: Alamofire + RxSwift 기반 DataTransferService
- **로컬 DB**: Realm
- **의존성 관리**: Swift Package Manager
- **프로젝트 관리**: Vanilla Xcode (.xcodeproj)

## 향후 개발 로드맵 (리팩토링 계획)

> **반드시 참고**: `/Users/test/Desktop/Task/Develop/Swift/리팩토링/` 폴더
>
> 이 폴더에 메인 현황 + Phase별 상세 문서가 분리되어 있다.
> 새 대화 시작 시 메인 문서를 먼저 읽어서 현재 진행 상황을 파악한다.

### 문서 구조
| 파일 | 역할 |
|------|------|
| `리팩토링/Mople-Evolution.md` | **메인** — 전체 진행률, 로드맵, 마일스톤 |
| `리팩토링/Phase-0-협업기반.md` | Phase 0 상세 + 체크박스 + 작업로그 |
| `리팩토링/Phase-1-테스트.md` | Phase 1 상세 |
| `리팩토링/Phase-2-CICD.md` | Phase 2 상세 |
| `리팩토링/Phase-3-Async전환.md` | Phase 3 상세 |
| `리팩토링/Phase-4-Swift6.md` | Phase 4 상세 |
| `리팩토링/Phase-5-SwiftUI.md` | Phase 5 상세 |
| `리팩토링/Phase-6-Tuist.md` | Phase 6 상세 |
| `리팩토링/Phase-7-DB전략.md` | Phase 7 상세 |

### Phase 요약
| Phase | 내용 | 상태 |
|-------|------|------|
| 0 | 협업 기반 (SwiftLint, README, 브랜치 전략) | 미시작 |
| 1 | 테스트 환경 (Swift Testing) | 미시작 |
| 2 | CI/CD (GitHub Actions + Fastlane) | 미시작 |
| 3 | RxSwift → Swift Concurrency (async/await) | 미시작 |
| 4 | Swift 6 Strict Concurrency | 미시작 |
| 5 | SwiftUI 점진적 도입 | 미시작 |
| 6 | Tuist + 모듈화 | 미시작 |
| 7 | DB 전략 (Realm → SwiftData 검토) | 미시작 |

## 작업 규칙

### Phase 진행 방식
- 사용자가 "Phase N 시작하자"라고 하면:
  1. 메인 문서(`리팩토링/Mople-Evolution.md`)를 읽어 전체 현황 파악
  2. 해당 Phase 문서(`리팩토링/Phase-N-xxx.md`)를 읽어 상세 내용 확인
  3. 체크박스의 미완료 항목부터 함께 구현 시작
- 사용자는 이 분야 도구/개념에 익숙하지 않으므로, 처음 접하는 것은 설명하며 진행

### 문서 갱신 규칙
Dataview가 체크박스를 자동 집계하므로 수동 갱신은 최소화됨.

작업 완료 시 갱신할 것:
1. **Phase 문서**: 체크박스 `[ ]` → `[x]` + 작업 로그 테이블에 날짜/내용 추가
2. **메인 문서 로드맵 테이블**: 해당 Phase 상태 `⬜` → `✅` (Phase 전체 완료 시)
3. **이 문서**: Phase 완료 시 상태를 `완료`로 갱신

> 프로그레스 바, 전체 진행률, 마일스톤은 Dataview가 자동 계산한다.

### 진행 상황 확인
- "지금 어디까지 했지?" → 메인 문서를 읽고 프로그레스 바 기반으로 현황 브리핑

### 코드 작업 규칙
- 작업 완료 시 주요 코드에 기능 설명 주석 추가
- Clean Architecture 레이어 구분 준수 (Domain은 외부 의존성 없이 유지)
- 신규 코드는 로드맵 방향에 맞춰 작성 (가능하면 async/await, SwiftUI 우선)

## 배포 규칙

### TestFlight 배포 (테스트)
- 사용자가 "테스트플라이트 올려줘" 요청 시:
  1. 대화에서 변경사항을 파악해 changelog 초안 작성
  2. 사용자에게 "이 내용이면 될까?" 확인
  3. 확인 후 `fastlane beta changelog:"내용"` 실행
- 실행 전 반드시 `export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8` 설정

### App Store 릴리즈 (출시)
- 사용자가 "릴리즈 해줘" / "배포해줘" / "앱스토어 올려줘" 요청 시:
  1. **반드시 먼저 확인**: "업로드만 할까, 심사 제출까지 할까?"
  2. changelog 초안 작성 → 사용자 확인
  3. 선택에 따라 실행:
     - 업로드만: `fastlane deploy_release changelog:"내용"`
     - 심사 제출까지: `fastlane deploy_release submit:true changelog:"내용"`
- `deploy_release`가 자동으로 처리하는 것:
  - develop → release/v{버전} 브랜치 머지
  - 버전 태그 생성 + push
  - 빌드 + App Store 업로드
  - develop 브랜치로 복귀

## Git 커밋 시 주의사항
- **`git add -A` 사용 전 반드시 `.gitignore` 확인** — 추적하면 안 되는 파일이 포함되지 않는지 점검
- **대용량 파일/폴더 경계 대상**:
  - `.spm-packages/` — SPM 캐시 (firebase 226MB, realm 136MB 등 100MB 초과 파일 포함)
  - `DerivedData/`, `build/`, `Pods/`
- GitHub 파일 크기 제한: **100MB** (초과 시 push 거부)
- 새로운 폴더가 staged에 처음 등장하면 `.gitignore` 대상인지 반드시 확인할 것

## 옵시디언 정리 규칙
- "정리해줘" 요청 시 대화 내용을 옵시디언에 마크다운으로 정리
- 저장 경로: `/Users/test/Desktop/Task/Develop/Swift/`
- 리팩토링 관련: `/Users/test/Desktop/Task/Develop/Swift/리팩토링/`
- 파일명 형식: `주제.md`
- 문서 형식:
  ```
  ---
  date: YYYY-MM-DD
  tags: [관련 태그들]
  ---
  # 주제 제목
  ## 작업 결과물
  ## 과정
  ## 핵심 로직
  ## 사용한 방식
  ## TODO
  ```
