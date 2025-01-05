//
//  ProfileSetMock.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class SignUpRepositoryMock: SignUpRepo {
    
    func getRandomNickname() -> Single<Data> {
        return Single.just("랜덤닉네임".data(using: .utf8) ?? Data())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
    
    func signUp(requestModel: SignUpRequest) -> Single<Void> {
        return Single.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}




