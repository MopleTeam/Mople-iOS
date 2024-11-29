//
//  ProfileEditRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import RxSwift

protocol ProfileEditRepo {
    func editProfile(nickname: String, imagePath: String?) -> Single<Void>
}


