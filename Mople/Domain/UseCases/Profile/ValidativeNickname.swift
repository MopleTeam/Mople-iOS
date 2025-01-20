//
//  ValidativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol ValidativeNickname {
    func checkNickname(_ nickname: String) -> Single<Bool>
}

final class NicknameManagerUseCase: ValidativeNickname {
    
    let nickNameRepo: NicknameRepo
    
    init(nickNameRepo: NicknameRepo) {
        self.nickNameRepo = nickNameRepo
    }
        
    func checkNickname(_ nickname: String) -> Single<Bool> {
        return nickNameRepo.isNicknameExists(nickname)
            .map { String(data: $0, encoding: .utf8) }
            .map { self.checkBooleanString($0) }
    }
    
    private func checkBooleanString(_ bool: String?) -> Bool {
        switch bool {
        case "true": return true
        default: return false
        }
    }
}
