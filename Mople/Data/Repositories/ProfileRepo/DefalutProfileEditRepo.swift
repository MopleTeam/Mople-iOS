//
//  DefalutProfileEditRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import RxSwift

final class DefaultProfileEditRepo:BaseRepositories,  ProfileEditRepo {

    func editProfile(nickname: String, imagePath: String?) -> Single<Void> {
        return networkService.authenticatedRequest { 
            try APIEndpoints.setupProfile(nickname: nickname,
                                          imagePath: imagePath)
        }
    }
}
