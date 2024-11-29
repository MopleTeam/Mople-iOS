//
//  ValidatorNicknameUseCase.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import RxSwift

protocol ValidatorNickname {
    func validatorNickname(_ nickname: String) -> Single<Bool>
}

final class ValidatorNicknameUseCase: ValidatorNickname {
    
    let repo: NicknameValidationRepo
    
    init(repo: NicknameValidationRepo) {
        self.repo = repo
    }
    
    func nickNameDuplicateCheck(_ nickname: String) -> Single<Bool> {
        return repo.isNicknameExists(nickname)
            .debug("# 30")
            .map { String(data: $0, encoding: .utf8) }
            .map { self.checkBooleanString($0) }
    }
    
    private func checkBooleanString(_ bool: String?) -> Bool {
        switch bool {
        case "true": return true
        default: return false
        }
    }
    
    func validatorNickname(_ nickname: String) -> Single<Bool> {
        return Single.deferred {
            do {
                let _ = try NickNameValidator.checkNickname(nickname)
                return self.nickNameDuplicateCheck(nickname)
            } catch {
                return .error(error)
            }
        }
    }
}
