//
//  UserInfoStorage.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import RealmSwift

final class UserInfoStorage {
    
    static let shared = UserInfoStorage()
    
    private init() {
        print(#function, #line, "#3 프로필 저장소 생성" )
        fetchUserInfo()
    }
    
    private(set) var userInfo: UserInfo?
    
    public var hasUserInfo: Bool {
        return userInfo != nil
    }
    
    private let realmDB = try! Realm()
    
    private var userInfoData: Results<UserInfoEntity> {
        return realmDB.objects(UserInfoEntity.self)
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
    }
    
//    let adjustCount = isIncreasing ? 1 : -1
//
//    guard let userInfo = userInfoData.first else { return }
//
//    try! realmDB.write({
////            userInfo.notifyCount += adjustCount
//    })
//
//    self.userInfo?.notifyCount += adjustCount
    
    func resetNotifyCount() {
        guard let userInfo = userInfoData.first else { return }
    
        try! realmDB.write({
            userInfo.notifyCount = 0
        })
    
        self.userInfo?.notifyCount = 0
    }
}


