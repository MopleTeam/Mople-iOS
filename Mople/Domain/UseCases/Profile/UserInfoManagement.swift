//
//  EditProfile.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import RxSwift

protocol UserInfoManagement {
    func fetchUserInfo() -> Single<Void>
    func editProfile(nickname: String, imagePath: String?) -> Single<Void>
}

final class UserInfoManagementUseCase: UserInfoManagement {
    
    private let userInfoRepo: UserInfoRepo
    
    init(userInfoRepo: UserInfoRepo) {
        print(#function, #line, "LifeCycle Test FetchUserInfoUseCase Created" )
        self.userInfoRepo = userInfoRepo
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test FetchUserInfoUseCase Deinit" )
    }
}

#warning("에러처리")
extension UserInfoManagementUseCase {
    func fetchUserInfo() -> Single<Void> {
        return self.userInfoRepo.getUserInfo()
            .observe(on: MainScheduler.instance)
            .map {
                print(#function, #line, "# userProfile : \($0)" )
                UserInfoStorage.shared.addEntity($0.toDomain())
            }
    }
    
    func editProfile(nickname: String,
                     imagePath: String?) -> Single<Void> {
        return self.userInfoRepo.editProfile(nickname: nickname,
                                             imagePath: imagePath)
    }
}


