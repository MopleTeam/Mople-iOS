//
//  DefalutProfileEditRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import RxSwift

final class DefaultProfileEditRepo: ProfileEditRepo {

    private let networkService: AppNetWorkService

    
    init(networkService: AppNetWorkService) {
        self.networkService = networkService
    }

    func editProfile(nickname: String, imagePath: String?) -> Single<Void> {
        return networkService.authenticatedRequest { () throws -> Endpoint<Void> in
            try APIEndpoints.setupProfile(nickname: nickname,
                                          imagePath: imagePath)
        }
    }
}
