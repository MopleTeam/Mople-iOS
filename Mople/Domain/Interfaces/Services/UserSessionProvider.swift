//
//  UserSessionProvider.swift
//  Mople
//
//  Created by CatSlave on 4/10/26.
//

import Foundation

/// 현재 로그인한 사용자의 세션 정보를 제공하는 프로토콜
/// Domain 레이어에서 UserInfoStorage 직접 참조를 제거하기 위한 추상화
protocol UserSessionProvider {
    var currentUserId: Int? { get }
}
