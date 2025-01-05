//
//  EditProfileMock.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import RxSwift

final class FetchProfileMock: FetchProfile {
    
    func fetchProfile() -> Single<UserInfo> {
        return Observable.just(UserInfo(id: 1,
                                        name: "테스트테스트",
                                        imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
