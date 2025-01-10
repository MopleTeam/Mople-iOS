//
//  EditProfile.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import Foundation
import RxSwift

protocol FetchUserInfo {
    func fetchUserInfo() -> Single<Void>
}

final class FetchUserInfoUseCase: FetchUserInfo {
    
    let userInfoRepo: UserInfoRepo
    
    init(userInfoRepo: UserInfoRepo) {
        print(#function, #line, "LifeCycle Test FetchUserInfoUseCase Created" )

        self.userInfoRepo = userInfoRepo
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test FetchUserInfoUseCase Deinit" )
    }
}

#warning("에러처리")
extension FetchUserInfoUseCase {
    func fetchUserInfo() -> Single<Void> {
        return self.userInfoRepo.getUserInfo()
            .observe(on: MainScheduler.instance)
            .map {
                print(#function, #line, "# userProfile : \($0)" )
                UserInfoStorage.shared.addEntity($0.toDomain())
            }
    }
}
