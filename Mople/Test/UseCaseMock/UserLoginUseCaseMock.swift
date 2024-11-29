//
//  UserLoginUseCaseMock.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import Foundation
import RxSwift

final class UserLoginMock: SignIn {
    func login(_ platform: LoginPlatform) -> Single<Void> {
        return Single.just(())
    }
}
