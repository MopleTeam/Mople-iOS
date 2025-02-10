//
//  ValidativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol ValidationNickname {
    func execute(_ nickname: String) -> Single<Bool>
}

final class ValidationNicknameUseCase: ValidationNickname {
    
    let validationNicknameRepo: NicknameRepo
    
    init(validationNicknameRepo: NicknameRepo) {
        self.validationNicknameRepo = validationNicknameRepo
    }
        
    func execute(_ nickname: String) -> Single<Bool> {
        return validationNicknameRepo.isNicknameExists(nickname)
            .map { String(data: $0, encoding: .utf8) }
            .map { self.handleRequestValue($0) }
    }
    
    private func handleRequestValue(_ value: String?) -> Bool {
        switch value {
        case "true": return true
        default: return false
        }
    }
}
