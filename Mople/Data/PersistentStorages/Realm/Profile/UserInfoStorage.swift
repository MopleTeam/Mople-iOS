//
//  UserInfoStorage.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import UIKit
import RealmSwift
import RxSwift

final class UserInfoStorage {
    
    // MARK: - Variables
    private(set) var userInfo: UserInfo?
    
    // MARK: - Realm
    private let realmDB = try! Realm()
    
    private var userInfoData: Results<UserInfoEntity> {
        return realmDB.objects(UserInfoEntity.self)
    }
    
    // MARK: - Single
    static let shared = UserInfoStorage()
    
    // MARK: - LifeCycle
    private init() {
        fetchUserInfo()
    }
    
    func fetchUserInfo() {
        guard let userInfoEntity = userInfoData.first else { return }
        self.userInfo = userInfoEntity.toDomain()
    }
    
    func addEntity(_ userInfo: UserInfo) {
        self.userInfo = userInfo
        try! realmDB.write({
            realmDB.add(UserInfoEntity(userInfo))
        })
    }
    
    func deleteEnitity() {    
        try! realmDB.write({
            userInfoData.forEach { [weak self] in
                self?.realmDB.delete($0)
            }
        })
    }
    
    func updateLocation(_ location: Location) {
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
    
    func updateProfile(_ profile: UserInfo) {
        guard let userInfo = userInfoData.first else { return }
        
        try! realmDB.write({
            userInfo.updateProfile(profile)
        })
        
        self.userInfo?.updateProfile(profile)
    }
    
    func updateNotifyCount(_ count: Int) {
        guard let userInfo = userInfoData.first else { return }
    
        try! realmDB.write({
            userInfo.notifyCount = count
        })
    
        self.userInfo?.notifyCount = count
        postNotifyCountChanged()
    }
    
    func adjustNotifyCount(isIncreasing: Bool) {
        let adjustCount = isIncreasing ? 1 : -1
        
        guard let userInfo = userInfoData.first else { return }
        
        try! realmDB.write({
            userInfo.notifyCount += adjustCount
        })
        
        self.userInfo?.notifyCount += adjustCount
        postNotifyCountChanged()
    }
    
    func resetNotifyCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0

        guard let userInfo = userInfoData.first else { return }
    
        try! realmDB.write({
            userInfo.notifyCount = 0
        })
    
        self.userInfo?.notifyCount = 0
        postNotifyCountChanged()
    }
    
    private func postNotifyCountChanged() {
        NotificationManager.shared.post(name: .changedNotifyCount)
    }
}


