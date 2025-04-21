//
//  UserRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//
import Foundation
import RxSwift

protocol AuthenticationRepo {
    func signIn(social: SocialInfo) -> Single<Void>
    func signUp(requestModel: SignUpRequest) -> Single<Void>
    func signOut(userId: Int) -> Single<Void>
    func deleteAccount() -> Single<Void>
}



