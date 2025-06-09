# Version 
![iOS-Swift](https://img.shields.io/badge/platform-iOS-blue)
![Swift Version](https://img.shields.io/badge/swift-15.0-orange) 

# Download
<a href="https://apps.apple.com/kr/app/모임플래너/id6738402542">
  <img src="https://github.com/user-attachments/assets/dd57805b-1111-473c-b30d-3cfa0ad01112"
       alt="모임플래너 앱(iOS) 이미지"
       width="320"
       style="border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); vertical-align: middle;" />
</a>
<br>
<a href="https://play.google.com/store/apps/details?id=com.moim.moimtable">
  <img src="https://github.com/user-attachments/assets/2be162b3-b6b6-4120-b7a6-4c018aacc85b"
       alt="모임플래너 앱(안드로이드) 이미지"
       width="320"
       style="border-radius: 12px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); vertical-align: middle;" />
</a>

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

## 시연 영상
<div align="center">
  <table>
    <tr>
      <td align="center">
        <b>스플래시</b><br>
        <img src="https://github.com/user-attachments/assets/3066910a-1e51-42fa-af18-20fbcc5c3f04" width="250">
      </td>
      <td align="center">
        <b>로그인</b><br>
        <img src="https://github.com/user-attachments/assets/f8830482-3997-4a3c-a715-14828ed6c1e8" width="250">
      </td>
      <td align="center">
        <b>회원가입</b><br>
        <img src="https://github.com/user-attachments/assets/72d7ef08-a9e0-49cf-b97a-90899fae5005" width="250">
      </td>
    </tr>
    <tr>
      <td align="center">
        <b>달력 화면 1</b><br>
        <img src="https://github.com/user-attachments/assets/243bdf88-f61f-4a78-89ac-f6028805e2b5" width="250">
      </td>
      <td align="center">
        <b>달력 화면 2</b><br>
        <img src="https://github.com/user-attachments/assets/56c9aad6-0929-41eb-96f3-4edf8a5ba4e9" width="250">
      </td>
      <td align="center">
        <b>시트뷰</b><br>
        <img src="https://github.com/user-attachments/assets/7967ee9d-8128-47c1-92f0-0e61f8582bb5" width="250">
      </td>
    </tr>
    <tr>
      <td align="center">
        <b>알림창</b><br>
        <img src="https://github.com/user-attachments/assets/e7abfbb5-5a66-4411-a86a-cdbd31cce596" width="250">
      </td>
      <td align="center">
        <b>댓글</b><br>
        <img src="https://github.com/user-attachments/assets/e361c1cb-20aa-43fe-bad8-8726923624f3" width="250">
      </td>
      <td align="center">
        <b>로그아웃</b><br>
        <img src="https://github.com/user-attachments/assets/5b0e6bb3-2c3f-4c7c-b6f2-79ebfcefb36a" width="250">
      </td>
    </tr>
  </table>
</div>
