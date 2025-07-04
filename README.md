# 모플 - 모임 및 일정 플래너
![Card-Image](https://github.com/user-attachments/assets/bfad296c-637d-47e1-a8da-2284f5c8b0e5)
<br>
모임의 시작부터 마무리까지, 오직 필요한 사람들과만 공유되는 일정 관리.

모플은 친구, 팀, 소모임 등 비공개 모임을 쉽게 만들고,
일정 변경도 빠르게 확인할 수 있도록 도와주는 모임 전용 일정 관리 앱입니다.

## Download
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

## 시연 영상
<div align="center">
 <table>
   <tr>
     <td align="center">
       <b>스플래시</b><br>
       <img src="https://github.com/user-attachments/assets/bc6d145f-d34a-44a8-8930-cae15f5b7fc7" width="250">
     </td>
     <td align="center">
       <b>로그인</b><br>
       <img src="https://github.com/user-attachments/assets/9017d720-4d21-497f-b5df-6e6b13292aaa" width="250">
     </td>
     <td align="center">
       <b>회원가입</b><br>
       <img src="https://github.com/user-attachments/assets/5bfb5eba-bdeb-4a08-8c79-6644a9e39854" width="250">
     </td>
   </tr>
   <tr>
     <td align="center">
       <b>로그아웃</b><br>
       <img src="https://github.com/user-attachments/assets/f0e78dda-0beb-4248-a4ec-d991d09bd633" width="250">
     </td>
     <td align="center">
       <b>캘린더</b><br>
       <img src="https://github.com/user-attachments/assets/66aa8aac-ad35-428f-8d7f-51f28b6f36ac" width="250">
     </td>
     <td align="center">
       <b>캘린더 2</b><br>
       <img src="https://github.com/user-attachments/assets/4f1a6bab-d6bb-4822-9474-69f12505d2f8" width="250">
     </td>
   </tr>
   <tr>
     <td align="center">
       <b>커스텀 시트뷰</b><br>
       <img src="https://github.com/user-attachments/assets/65ac0d18-776c-4b92-b58c-398badf0b042" width="250">
     </td>
     <td align="center">
       <b>커스텀 얼럿</b><br>
       <img src="https://github.com/user-attachments/assets/9ba93de5-9d6d-4353-9401-8d3f7403954c" width="250">
     </td>
     <td align="center">
       <b>댓글</b><br>
       <img src="https://github.com/user-attachments/assets/8ee6849c-1e36-4c96-b0a5-30319a745091" width="250">
     </td>
   </tr>
 </table>
</div>

## Architecture
<img width="800" alt="아키텍쳐 구성도_1" src="https://github.com/user-attachments/assets/7365c52c-5b93-4247-a3d5-462bdedc83b9" />

## Stack
### 🏗️ Architecture & Design Pattern
| 분야 | 기술 스택 |
|------|-----------|
| 아키텍처 | Clean Architecture |
| 상태 관리 | ReactorKit |
| 비동기 처리 | RxSwift |
| 의존성 관리 | DI Container | 
| 화면이동 관리 | Coordinator Parttern | 

### 🌐 Network & Data
| 분야 | 기술 스택 |
|------|-----------|
| 네트워크 통신 | URLSession + RxSwift |
| 이미지 로딩 & 캐싱 | Kingfisher |
| 이미지 업로드 | MultipartForm |
| 로컬 데이터 저장 | Realm + UserDefaults |
| 민감 정보 보호 | Keychain |

### 🔐 Authentication & External Services
| 분야 | 기술 스택 |
|------|-----------|
| 로그인 시스템 | Kakao Login, Apple Login |
| 지도 서비스 | Naver Maps (NMapsMap) |
| 캘린더 UI | FSCalendar |
| 알림 & 분석 | Firebase |

### 🛠️ Development Tools
| 분야 | 기술 스택 |
|------|-----------|
| 리소스 관리 | SwiftGen |
| 협업 도구 | Jira, Notion, Discord, Figma |

## Experience
### 🏗️ Architecture & Design Pattern
| 기술 | 주요 경험 |
|------|-----------|
| **Clean Architecture** | • Presentation-Domain-Data 계층 분리<br>• 의존성 역전 원칙 적용으로 결합도 최소화<br>• DI Container를 통한 테스트 친화적 설계 |
| **Coordinator Pattern** | • 복잡한 화면 관리 및 메모리 누수 방지<br>• 앱/로그인/메인 코디네이터 계층 관리<br>• 탭바 컨트롤러 패턴 적용 |
| **ReactorKit + RxSwift** | • 단방향 데이터 흐름(UDF) 상태 관리<br>• RxCocoa UI 바인딩 및 RxDataSource 활용<br>• Action → UseCase → State 업데이트 플로우 |

### 🌐 Network & Data Management
| 기술 | 주요 경험 |
|------|-----------|
| **네트워크 통신** | • URLSession + RxSwift 기반 비동기 처리<br>• DTO ↔ Domain Model 매핑 처리<br>• 공통 에러 처리 및 페이징 구현 |
| **인증 시스템** | • 소셜 로그인(Kakao, Apple) 구현<br>• JWT 토큰 기반 인증 및 자동 갱신<br>• Keychain 보안 정보 관리 |

### 🎨 UI/UX & User Experience
| 기술 | 주요 경험 |
|------|-----------|
| **커스텀 UI** | • 재사용 가능한 컴포넌트 설계<br>• 커스텀 Alert 및 시트뷰 구현 |
| **애니메이션** | • 부드러운 화면 전환 애니메이션<br>• 네비게이션 Transition 구현 |
| **지도 & 위치** | • 장소 검색 및 지도 표시<br>• 외부 지도앱 연동 길찾기 |
| **알림 & 딥링크** | • 푸시 알림 기반 화면 이동<br>• 초대링크 파싱 및 모임 가입 처리 |
## Issue Rule
**[Prefix] - 이슈내용**
> **ex)** [Feat] - 홈 화면 구현

## PR Rule
**[Prefix] #이슈번호 - 전체 작업 요약**
> **ex)** [Feat] #1 - 홈 화면 구현완료

## Commit Rule
**[Prefix] #이슈번호 - 세부 작업 요약**
```
[Feat]: 새로운 기능 개발
[Fix]: 버그 수정 및 오류 개선
[Design]: UI/UX 구현 및 화면 작업
[Refactor]: 코드 리팩토링 및 구조 개선
[Add]: 외부 라이브러리 및 의존성 추가
[Remove]: 불필요한 파일 및 코드 제거
[Chore]: 빌드 설정, 환경 구성, 파일 구조 변경
[Docs]: 문서화 작업 (README, 주석 등)
[Style]: 코드 스타일링 및 포맷팅
[Setting]: 프로젝트 초기 설정 및 전역 환경 구성
```
> ex) [Feat] #1 - 홈 화면 컴포넌트 생성

## Git Flow
1. 이슈 등록
2. 작업 브랜치 생성 (dev에서 분기)
3. 로컬 개발 작업 / 커밋 / 푸쉬
4. PR 생성 (작업 브랜치 -> dev)
5. 코드 리뷰 & 승인
6. dev로 머지
7. 작업 브랜치 삭제

## Version 
![iOS-Swift](https://img.shields.io/badge/platform-iOS-blue)
![Swift Version](https://img.shields.io/badge/swift-15.0-orange) 
