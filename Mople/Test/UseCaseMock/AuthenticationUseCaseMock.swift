//
//  UserLoginUseCaseMock.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import RxSwift

final class AuthenticationUseCaseMock: SignUp {
    func execute(nickname: String, imagePath: String?) -> RxSwift.Single<Void> {
        return Single.just(())

    }
    
    func signIn(_ platform: LoginPlatform) -> Single<Void> {
        return Single.just(())
    }
}
