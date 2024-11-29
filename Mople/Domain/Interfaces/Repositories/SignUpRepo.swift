//
//  SignUpRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import Foundation
import RxSwift

protocol SignUpRepo {
    func getRandomNickname() -> Single<Data>
    
    func signUp(nickname: String,
                imagePath: String?,
                socialAccountInfo: SocialAccountInfo) -> Single<Void>
}

