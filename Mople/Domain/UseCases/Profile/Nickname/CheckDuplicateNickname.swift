//
//  ValidativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol CheckDuplicateNickname {
    func execute(_ nickname: String) -> Single<Bool>
}

final class CheckDuplicateNicknameUseCase: CheckDuplicateNickname {
    
    private let duplicateCheckRepo: NicknameRepo
    
    init(duplicateCheckRepo: NicknameRepo) {
        self.duplicateCheckRepo = duplicateCheckRepo
    }
        
    func execute(_ nickname: String) -> Single<Bool> {
        return duplicateCheckRepo.isNicknameExists(nickname)
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
