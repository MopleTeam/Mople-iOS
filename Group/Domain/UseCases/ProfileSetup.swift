//
//  ProfileSetup.swift
//  Group
//
//  Created by CatSlave on 8/26/24.
//

import Foundation
import RxSwift

protocol ProfileSetup {
    func checkNickName(name: String) -> Single<Bool>
}

final class ProfileSetupImpl: ProfileSetup {
    
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
