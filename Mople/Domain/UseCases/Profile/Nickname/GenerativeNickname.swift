//
//  GenerativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol GenerativeNickname {
    func executue() -> Single<String?>
}

final class GenerateNicknameUseCase: GenerativeNickname {
    
    let nickNameRepo: NicknameRepo
    
    init(nickNameRepo: NicknameRepo) {
        self.nickNameRepo = nickNameRepo
    }
    
    func executue() -> Single<String?> {
        self.nickNameRepo.generatorNickname()
            .map { String(data: $0, encoding: .utf8)  }
    }
}
