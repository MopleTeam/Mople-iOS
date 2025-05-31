//
//  FetchUserInfo.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//
import UIKit
import RxSwift

protocol FetchUserInfo {
    func execute() -> Observable<Void>
}

final class FetchUserInfoUseCase: FetchUserInfo {
    
    private let userInfoRepo: UserInfoRepo
    
    init(userInfoRepo: UserInfoRepo) {
        self.userInfoRepo = userInfoRepo
    }
    
    func execute() -> Observable<Void> {
        return self.userInfoRepo.updateUserInfo()
            .asObservable()
    }
}
