//
//  TextStyle.swift
//  Group
//
//  Created by CatSlave on 11/11/24.
//

import Foundation

struct TextStyle {
    enum App {
        static let title = "모임관리"
        static let subTitle = "모임부터 약속까지 간편한 관리"
    }
    
    enum Login {
        static let kakao = "카카오로 시작하기"
        static let apple = "Apple로 시작하기"
    }
    
    enum Profile {
        static let title = "자신을 나타낼\n프로필을 설정해주세요"
        static let nameTitle = "닉네임"
        static let checkBtnTitle = "중복확인"
        static let duplicateText = "이미 사용중인 닉네임 입니다."
        static let validateTitle = "사용 가능한 닉네임 입니다."
        static let editTitle = "수정"
        static let createTitle = "서비스 시작하기"
    }
    
    enum Home {
        static let moreBtnTitle = "더보기"
        static let createGroup = "새로운\n모임 만들기"
        static let createSchedule = "새로운\n일정 만들기"
    }
    
    enum DatePicker {
        static let completedTitle = "완료"
    }
    
    enum GroupList {
        static let emptyTitle = "새로운 모임을 추가해주세요."
    }
    
    enum Setup {
        static let version = Bundle.main.releaseVersionNumber ?? "0.0"
        static let notifyTitle = "알림 관리"
        static let policyTitle = "개인정보 처리방침"
        static let versionTitle = "버전정보"
        static let logoutTitle = "로그아웃"
        static let resignTitle = "회원탈퇴"
    }
}
