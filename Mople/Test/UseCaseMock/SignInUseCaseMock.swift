//
//  SignInUseCaseMock.swift
//  Mople
//
//  Created by CatSlave on 2/1/25.
//

import UIKit
import RxSwift

final class SignInUseCaseMock: SignIn {
    func execute(platform: LoginPlatform) -> Single<Void> {
        return Single.just(())
    }
}

