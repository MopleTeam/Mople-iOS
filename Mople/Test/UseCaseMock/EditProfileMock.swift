//
//  EditProfileMock.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import UIKit
import RxSwift

final class ProfileEditMock: ProfileEdit {
    func editProfile(nickname: String, image: UIImage?) -> Single<Void> {
        return Observable.just(())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
