//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit
import RxSwift

protocol SignUp {
    func execute(nickname: String, imagePath: String?) -> Single<Void>
}

final class SignUpUseCase: SignUp {

    private let authenticationRepo: AuthenticationRepo
    private let platForm: SocialInfo
    
    init(authenticationRepo: AuthenticationRepo,
         platForm: SocialInfo) {
        print(#function, #line, "LifeCycle Test SignInUseCase Created" )
        self.authenticationRepo = authenticationRepo
        self.platForm = platForm
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SignInUseCase Deinit" )
    }
    
    // MARK: - SignUp
    func execute(nickname: String,
                imagePath: String?) -> Single<Void> {
        return self.authenticationRepo.signUp(requestModel: .init(social: platForm,
                                                                  nickname: nickname,
                                                                  imagePath: imagePath))
    }
}
