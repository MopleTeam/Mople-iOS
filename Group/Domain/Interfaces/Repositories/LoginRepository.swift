//
//  UserRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//
import Foundation
import RxSwift

protocol LoginRepository {
    func userLogin(authCode: String) -> Single<Void>
}



