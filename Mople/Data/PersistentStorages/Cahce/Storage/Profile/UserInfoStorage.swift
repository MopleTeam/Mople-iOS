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
    
    private let realmDB = try! Realm()
    
    private var userInfoData: Results<UserInfoEntity> {
        return realmDB.objects(UserInfoEntity.self)
    }
    
    func fetchUserInfo() {
        guard let userInfoEntity = userInfoData.first else { return }
        self.userInfo = userInfoEntity.toDomain()
        print(#function, #line, "#3 프로필 업데이트 \(self.userInfo)" )
    }
    
    func addEntity(_ userInfo: UserInfo) {
        print(#function, #line, "#3 프로필 추가 \(userInfo)" )
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
    
}

