//
//  GenerativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol CreationNickname {
    func executue() -> Observable<String>
}

final class CreationNicknameUseCase: CreationNickname {
    
    let nickNameRepo: NicknameRepo
    
    init(nickNameRepo: NicknameRepo) {
        self.nickNameRepo = nickNameRepo
    }
    
    func executue() -> Observable<String> {
        self.nickNameRepo.creationNickname()
            .asObservable()
            .flatMap({ data -> Observable<String> in
                guard let nickname = String(data: data, encoding: .utf8) else {
                    return .empty()
                }
                return .just(nickname)
            })
    }
}
