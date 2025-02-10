//
//  GenerativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol CreationNickname {
    func executue() -> Single<String?>
}

final class CreationNicknameUseCase: CreationNickname {
    
    let nickNameRepo: NicknameRepo
    
    init(nickNameRepo: NicknameRepo) {
        self.nickNameRepo = nickNameRepo
    }
    
    func executue() -> Single<String?> {
        self.nickNameRepo.creationNickname()
            .map { String(data: $0, encoding: .utf8)  }
    }
}
