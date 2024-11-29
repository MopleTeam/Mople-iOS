//
//  NicknameDuplicateRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//
import Foundation
import RxSwift

final class NicknameDuplicationCheckRepositoryMock: NicknameValidationRepo {
    
    func isNicknameExists(_ name: String) -> Single<Data> {
        let randomBoolean = Bool.random() ? "true" : "false"
        let dataBoolean = randomBoolean.data(using: .utf8)
        return Single.just(dataBoolean ?? Data())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
