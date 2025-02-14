//
//  EditProfileMock.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import RxSwift

final class EditUserInfoMock: EditProfile {
    
    func execute(request: ProfileEditRequest) -> Single<Void> {
        return Observable.just(())
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .asSingle()
    }
}


