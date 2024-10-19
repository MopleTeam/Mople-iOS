//
//  ProfileSetup.swift
//  Group
//
//  Created by CatSlave on 8/26/24.
//

import Foundation
import RxSwift

protocol ProfileSetup {
    func getRandomNickname() -> Single<String?>
    func checkNickName(name: String) -> Single<Bool>
    func makeProfile(image: Data, nickName: String) -> Single<ProfileInfo>
}

final class ProfileSetupImpl: ProfileSetup {
    
    let repository: ProfileSetupRepository
    
    init(repository: ProfileSetupRepository) {
        self.repository = repository
    }
    
    func getRandomNickname() -> Single<String?> {

        return Single.create { emitter in
            
            self.repository.getRandomNickname()
                .map { String(data: $0, encoding: .utf8) }
                .subscribe(onSuccess: { name in
                    emitter(.success(name))
                }, onFailure: { err in
                    emitter(.failure(err))
                })
        }
    }
    
    func checkNickName(name: String) -> Single<Bool> {
        return Single.deferred {
            self.repository.checkNickname(name: name)
        }
    }
    
    func makeProfile(image: Data, nickName: String) -> Single<ProfileInfo> {
        return Single.deferred {
            self.repository.makeProfile(image: image, nickNmae: nickName)
                .map { $0.toDomain() }
        }
    }
}
