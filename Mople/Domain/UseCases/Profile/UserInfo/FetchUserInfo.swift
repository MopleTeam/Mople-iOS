//
//  FetchUserInfo.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//
import UIKit
import RxSwift

protocol FetchUserInfo {
    func execute() -> Single<Void>
}

final class FetchUserInfoUseCase: FetchUserInfo {
    
    private let userInfoRepo: UserInfoRepo
    
    init(userInfoRepo: UserInfoRepo) {
        print(#function, #line, "LifeCycle Test FetchUserInfoUseCase Created" )
        self.userInfoRepo = userInfoRepo
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test FetchUserInfoUseCase Deinit" )
    }
    
    func execute() -> Single<Void> {
        return self.userInfoRepo.updateUserInfo()
    }
}
