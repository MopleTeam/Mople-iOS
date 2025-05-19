# Version 
![iOS-Swift](https://img.shields.io/badge/platform-iOS-blue)
![Swift Version](https://img.shields.io/badge/swift-15.0-orange) 

# Download
![KakaoTalk_Photo_2025-05-19-10-46-08 002](https://github.com/user-attachments/assets/dd57805b-1111-473c-b30d-3cfa0ad01112)(https://apps.apple.com/kr/app/%EB%AA%A8%ED%94%8C-%EB%AA%A8%EC%9E%84%ED%94%8C%EB%9E%98%EB%84%88/id6738402542)

## Architecture
<img width="500" alt="아키텍쳐 구성도_1" src="https://github.com/user-attachments/assets/ed1d4cd5-574b-4293-84d9-0b0a4d0594e6" />

## Stack
- 아키텍처 & 설계 : Clean Architecture + ReactorKit
- 비동기 처리 : RxSwift
- 네트워크 통신 : URLSession + RxSwift
- 이미지 로딩 & 캐싱 : Kingfisher
- 이미지 업로드 : MultipartFrom
- 로컬 데이터 저장 : Realm + UserDefaults
- 민감 정보 보호 : Keychain
- 로그인 시스템 : Kakao, Apple
- 지도 시스템 : NMAPSMap
- 캘린더 : FSCalendar
- 알림 수신 및 화면 트랙킹 : Firebase
- 리소스 관리 : SwiftGen
- 협업 툴 : Jira, Notion, Discord, Figma

## Experience
### 🧱 클린 아키텍처
  - 관심사의 명확한 분리: Presentation - Domain - Data 계층으로 책임 분리
  - 유지보수성 및 테스트 용이성 향상
  - 의존성 역전 원칙 적용으로 모듈 간 결합도 최소화
  - DI Container 의존성 주입을 통해 테스트 시 mock/테스트 유연한 처리
 
### 🚀 화면 전환 & 코디네이터 패턴
  - 코디네이터를 활용한 복잡한 화면 관리와 메모리 누수 방지
  - 앱 코디네이터 : 로그인, 메인 코디네이터 관리
  - 탭바 컨트롤러에 코디네이터 패턴 적용
 
### 🔁 RxSwift 기반 상태 관리
  - RxCocoa를 이용한 UI 컴포넌트와의 데이터 바인딩 처리
  - RxDataSource를 활용한 효율적이고 유연한 테이블뷰 및 컬렉션뷰 관리
  - Reactor을 이용한 단방향 데이터 흐름(UDF)을 통한 상태 관리 경험
  - 사용자 액션을 받아 UseCase를 실행하고, 그 결과를 바탕으로 상태(State)를 업데이트
  - 각 계층의 명확한 역할 분리로 유지보수 및 테스트 용이성 확보

### 🔐 로그인 및 인증 시스템
  - 소셜 로그인(Kakao, Apple)을 통한 로그인 
  - Keychain을 통한 보안 정보 관리
  - API 요청 시 JWT 토큰을 사용하여 인증 처리
  - 자동 토큰 갱신 로직 및 만료 처리 구현
  - 사용자 인증 및 권한 관리 경험

### 🖼️ 커스텀 UI 및 Alert
  - 재사용 가능한 커스텀 뷰 및 컴포넌트 구현 경험
  - 커스텀 Alert 설계 및 구현

### 🌐 네트워크 통신 및 에러 처리
  - URLSession과 RxSwift 기반으로 효율적인 네트워크 처리
  - 공통 에러 처리 로직 설계 및 사용자 친화적인 에러 처리 구현
  - 네트워크 응답 모델(DTO)과 도메인 모델 간 변환(Mapping) 처리 경험
  - 효율적인 데이터 요청을 위한 페이징 처리 구현
 
### 🔔 알림 & 딥링크
  - 시스템 알림 수신을 통한 특정 화면 이동 구현
  - 초대링크(Scheme)를 통해 앱 실행 시 초대코드 파싱 및 모임 가입 처리
 
### 🧭 지도 / 위치 기반 기능
  - 장소 검색 및 지도에 위치 표시 구현
  - 외부 지도 앱과 연동하여 길찾기 기능 제공

### 🎞️ 애니메이션
  - 부드러운 애니메이션을 활용한 화면 전환
  - 네비게이션 간 자연스러운 전환을 위한 Transition 구현
 
## 스크린샷
<img width="1000" alt="무제 12_1" src="https://github.com/user-attachments/assets/00fce7b8-715c-4c19-a4d6-7ae7244f13fc" />
<img width="1000" alt="무제 13_1" src="https://github.com/user-attachments/assets/d6cc99f3-7005-46ca-a4d0-6b032ec7db59" />

![May-05-2025 07-24-07](https://github.com/user-attachments/assets/e6accc75-38f0-426c-aae6-32c825035c38)
![May-05-2025 07-23-41](https://github.com/user-attachments/assets/94d311e1-cdb4-4894-a071-f1290f5394e4)
![May-05-2025 07-22-49](https://github.com/user-attachments/assets/a9d92888-eae6-4c0b-9469-af94019565b7)
