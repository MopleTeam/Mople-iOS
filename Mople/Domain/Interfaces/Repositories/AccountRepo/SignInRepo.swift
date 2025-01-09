//
//  UserRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//
import Foundation
import RxSwift

protocol SignInRepo {
    func signIn(social: SocialInfo) -> Single<Void>
}



