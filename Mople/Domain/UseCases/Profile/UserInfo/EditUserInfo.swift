//
//  EditProfile.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import RxSwift

protocol EditUserInfo {
    func execute(nickname: String, imagePath: String?) -> Single<Void>
}

final class EditUserInfoUseCase: EditUserInfo {
    
    private let userInfoRepo: UserInfoRepo
    
    init(userInfoRepo: UserInfoRepo) {
        print(#function, #line, "LifeCycle Test FetchUserInfoUseCase Created" )
        self.userInfoRepo = userInfoRepo
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test FetchUserInfoUseCase Deinit" )
    }
    
    func execute(nickname: String,
                     imagePath: String?) -> Single<Void> {
        return self.userInfoRepo.editProfile(nickname: nickname,
                                             imagePath: imagePath)
    }
}



