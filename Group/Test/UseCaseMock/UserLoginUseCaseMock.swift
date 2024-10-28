//
//  UserLoginUseCaseMock.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import Foundation
import RxSwift

final class UserLoginMock: UserLogin {
    func login(_ platform: LoginPlatform) -> RxSwift.Single<Void> {
        return Single.just(())
    }
}
