//
//  DefaultUserSessionProvider.swift
//  Mople
//
//  Created by CatSlave on 4/10/26.
//

import Foundation
import Domain

/// UserSessionProvider의 구현체
/// UserInfoStorage 싱글턴을 래핑하여 Domain 레이어에 주입한다
public final class DefaultUserSessionProvider: UserSessionProvider {
    public init() {}

    public var currentUserId: Int? {
        return UserInfoStorage.shared.userInfo?.id
    }
}
