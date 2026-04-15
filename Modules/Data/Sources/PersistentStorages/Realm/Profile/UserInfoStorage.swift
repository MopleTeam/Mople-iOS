//
//  UserInfoStorage.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import Domain
import RealmSwift

public final class UserInfoStorage {

    // MARK: - Variables
    public private(set) var userInfo: UserInfo?

    // MARK: - Realm
    private let realmDB = try! Realm()

    private var userInfoData: Results<UserInfoEntity> {
        return realmDB.objects(UserInfoEntity.self)
    }

    // MARK: - Single
    public static let shared = UserInfoStorage()

    // MARK: - LifeCycle
    private init() {
        fetchUserInfo()
    }

    public func fetchUserInfo() {
        guard let userInfoEntity = userInfoData.first else { return }
        self.userInfo = userInfoEntity.toDomain()
    }

    public func addEntity(_ userInfo: UserInfo) {
        self.userInfo = userInfo
        try! realmDB.write({
            realmDB.add(UserInfoEntity(userInfo))
        })
    }

    public func deleteEnitity() {
        try! realmDB.write({
            userInfoData.forEach { [weak self] in
                self?.realmDB.delete($0)
            }
        })
    }

    public func updateLocation(_ location: Location) {
        guard let userInfo = userInfoData.first,
              let longitude = location.longitude,
              let latitude = location.latitude else { return }

        try! realmDB.write({
            userInfo.updateLocation(longitude: longitude,
                                    latitude: latitude)
        })

        self.userInfo?.location = .init(longitude: longitude,
                                        latitude: latitude)
    }

    public func updateProfile(_ profile: UserInfo) {
        guard let userInfo = userInfoData.first else { return }

        try! realmDB.write({
            userInfo.updateProfile(profile)
        })

        self.userInfo?.updateProfile(profile)
    }

    public func updateNotifyStatus(hasNotify: Bool) {
        guard let userInfo = userInfoData.first else { return }
    
        try! realmDB.write({
            userInfo.hasNotify = hasNotify
        })
    
        self.userInfo?.hasNotify = hasNotify
        postNotifyCountChanged()
    }

    /// 알림 상태 변경을 NotificationCenter로 전파 (Presentation에서 뱃지 갱신 등에 사용)
    private func postNotifyCountChanged() {
        NotificationCenter.default.post(name: .changedNotifyStatus, object: nil)
    }
}


