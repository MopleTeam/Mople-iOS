//
//  ProfileSetupUseCaseMock.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import Foundation
import RxSwift

#warning("랜덤 닉네임 로그인 화면으로 옮기기")
final class ProfileSetupMock: ProfileSetup {
    func getRandomNickname() -> Single<String?> {
        return Single.just("랜덤닉네임")
            .delay(.seconds(3), scheduler: MainScheduler.instance)
    }
    
    func checkNickName(name: String) -> Single<Bool> {
        let randomBoolean = Bool.random()
        return Single.just(randomBoolean)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
    
    func makeProfile(image: Data, nickName: String) -> Single<Void> {
        return Single.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
