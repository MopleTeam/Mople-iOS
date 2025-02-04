//
//  UserLoginUseCaseMock.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import RxSwift

final class SignUpUseCaseMock: SignUp {
    func execute(nickname: String, imagePath: String?) -> RxSwift.Single<Void> {
        return Single.just(())

    }
}

