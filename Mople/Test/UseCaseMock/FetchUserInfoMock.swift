//
//  FetchUserInfoMock.swift
//  Mople
//
//  Created by CatSlave on 2/1/25.
//

import RxSwift

final class FetchUserInfoMock: FetchUserInfo {
    func execute() -> Single<Void> {
        return Observable.just(UserInfo(id: 5,
                                        name: "테스트테스트",
                                        imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
        .delay(.seconds(2), scheduler: MainScheduler.instance)
        .observe(on: MainScheduler.instance)
        .flatMap({ userInfo -> Single<Void> in
            UserInfoStorage.shared.addEntity(userInfo)
            return .just(())
        })
        .asSingle()
    }
}
