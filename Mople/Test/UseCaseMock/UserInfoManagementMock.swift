//
//  EditProfileMock.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import RxSwift

final class UserInfoManagementMock: EditUserInfo {
    
    func execute(nickname: String, imagePath: String?) -> Single<Void> {
        return Observable.just(())
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .asSingle()
    }
    
    
    func fetchUserInfo() -> Single<Void> {
        return Observable.just(UserInfo(id: 5,
                                        name: "테스트테스트",
                                        imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
        .delay(.seconds(2), scheduler: MainScheduler.instance)
        .observe(on: MainScheduler.instance)
        .map({ UserInfoStorage.shared.addEntity($0) })
        .asSingle()
    }
}
