//
//  UserRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//
import Foundation
import RxSwift

protocol LoginRepository {
    func userLogin(platForm: LoginPlatform, authCode: String) -> Single<Void>
}



