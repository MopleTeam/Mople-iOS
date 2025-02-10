//
//  UserLoginUseCaseMock.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import RxSwift

final class SignUpUseCaseMock: SignUp {
    func execute(request: SignUpRequest) -> RxSwift.Single<Void> {
        return Single.just(())

    }
}

