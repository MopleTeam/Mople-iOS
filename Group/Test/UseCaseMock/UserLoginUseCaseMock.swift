//
//  UserLoginUseCaseMock.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import Foundation
import RxSwift

class UserLoginMock: UserLogin {
    func login() -> Single<Void> {
        return Single.just(())
    }
}
