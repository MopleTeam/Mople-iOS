//
//  FCMTokenStorage.swift
//  Mople
//
//  Created by CatSlave on 4/16/25.
//

import Foundation
import Domain

private enum UserDefaultsKey: String {
    case fcmToken
}

public extension UserDefaults {

    static func saveFCMToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultsKey.fcmToken.rawValue)
    }

    static func getFCMToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsKey.fcmToken.rawValue)
    }

    static func deleteFCMToken() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.fcmToken.rawValue)
    }
}

