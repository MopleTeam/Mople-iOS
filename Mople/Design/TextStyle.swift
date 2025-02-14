//
//  TextStyle.swift
//  Group
//
//  Created by CatSlave on 11/11/24.
//

import Foundation

#warning("분류하지 않은 문구 정리하기")
// 에러
struct TextStyle {
    enum App {
        static let title = "모임관리"
        static let subTitle = "모임부터 약속까지 간편한 관리"
    }
    
    enum Tabbar {
        static let home = "홈"
        static let group = "모임"
        static let calendar = "일정관리"
        static let profile = "프로필"
    }
    
    enum Login {
        static let kakao = "카카오로 시작하기"
        static let apple = "Apple로 시작하기"
    }
    
    enum ProfileSetup {
        static let title = "자신을 나타낼\n프로필을 설정해주세요"
        static let nameTitle = "닉네임"
        static let typingName = "닉네임을 입력해주세요"
        static let checkBtnTitle = "중복확인"
        static let duplicateText = "이미 사용중인 닉네임 입니다."
        static let validateTitle = "사용 가능한 닉네임 입니다."
    }
    
    enum ProfileCreate {
        static let completedTitle = "모플 시작하기"
    }
    
    enum ProfileEdit {
        static let title = "프로필 수정"
        static let completedTitle = "저장"
    }
    
    enum Home {
        static let moreBtnTitle = "더보기"
        static let createGroup = "새로운\n모임 만들기"
        static let createSchedule = "새로운\n일정 만들기"
    }
    
    enum GroupList {
        static let title = "모임"
        static let emptyTitle = "새로운 모임을 추가해주세요"
    }
    
    enum Calendar {
        static let title = "일정관리"
        static let emptyTitle = "새로운 일정을 추가해주세요"
    }
    
    enum DatePicker {
        static let header = "날짜선택"
        static let completedTitle = "완료"
    }

    enum Profile {
        static let title = "마이페이지"
        static let version = Bundle.main.releaseVersionNumber ?? "0.0"
        static let notifyTitle = "알림 관리"
        static let policyTitle = "개인정보 처리방침"
        static let versionTitle = "버전정보"
        static let logoutTitle = "로그아웃"
        static let resignTitle = "회원탈퇴"
    }
    
    enum CreateGroup {
        static let title = "모임 생성하기"
        static let groupTitle = "모임 이름"
        static let placeholder = "모임 이름을 입력해주세요"
        static let completedTitle = "생성하기"
    }
    
    enum CreatePlan {
        static let title = "일정 생성하기"
        static let group = "모임 이름"
        static let groupInfo = "모임을 선택해주세요"
        static let plan = "약속 이름"
        static let planInfo = "일정을 입력해주세요"
        static let date = "날짜 선택"
        static let dateInfo = "날짜를 선택해주세요"
        static let time = "시간 선택"
        static let timeInfo = "시간을 선택해주세요"
        static let place = "장소 선택"
        static let placeInfo = "장소를 선택해주세요"
        static let completedTitle = "일정 생성"
    }
}
