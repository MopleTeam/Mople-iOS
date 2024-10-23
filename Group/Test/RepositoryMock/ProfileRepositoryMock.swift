//
//  ProfileSetMock.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class ProfileRepositoryMock: ProfileRepository {
    
    func getRandomNickname() -> Single<Data> {
        let randomNicknameData = "랜덤닉네임".data(using: .utf8)!
        return Single.just(randomNicknameData)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
    
    func checkNickname(name: String) -> Single<Bool> {
        let randomBoolean = Bool.random()
        return Single.just(randomBoolean)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
    
    func makeProfile(image: Data, nickname: String) -> Single<Void> {
        return Single.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
