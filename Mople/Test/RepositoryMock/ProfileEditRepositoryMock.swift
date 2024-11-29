//
//  ProfileEditRepositoryMock.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import RxSwift

final class ProfileEditRepositoryMock: ProfileEditRepo {
    func editProfile(nickname: String, imagePath: String?) -> Single<Void> {
        return Single.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
