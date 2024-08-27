//
//  ProfileSetup.swift
//  Group
//
//  Created by CatSlave on 8/26/24.
//

import Foundation
import RxSwift

protocol ProfileSetupUseCase {
    func checkNickName(name: String) -> Single<Bool>
}

final class ProfileSetupUseCaseImpl: ProfileSetupUseCase {
    
    let repository: ProfileSetupRepository
    
    init(repository: ProfileSetupRepository) {
        self.repository = repository
    }
    
    func checkNickName(name: String) -> Single<Bool> {
        return Single.deferred {
            self.repository.checkNickname(name: name)
        }
    }
    
//    func makeProfile
}
