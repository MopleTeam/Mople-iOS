//
//  SignUpRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import Foundation
import RxSwift

protocol NicknameRepo {
    func generatorNickname() -> Single<Data>
    func isNicknameExists(_ name: String) -> Single<Data>
}

