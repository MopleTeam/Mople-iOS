//
//  ProfileSetMock.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class NicknameManagerRepoMock: NicknameRepo {
    
    func isNicknameExists(_ name: String) -> Single<Data> {
        let randomBoolean = Bool.random() ? "true" : "false"
        let dataBoolean = randomBoolean.data(using: .utf8)
        return Single.just(dataBoolean ?? Data())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
    
    
    func creationNickname() -> Single<Data> {
        return Single.just("랜덤닉네임".data(using: .utf8) ?? Data())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}




