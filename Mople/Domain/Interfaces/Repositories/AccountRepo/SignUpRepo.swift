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
    
    func signUp(requestModel: SignUpRequest) -> Single<Void>
}

