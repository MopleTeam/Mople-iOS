//
//  UserRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import RxSwift

protocol UserRepository {
    func userLogin(authCode: String) -> Single<Void>
}
