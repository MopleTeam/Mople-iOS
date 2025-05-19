//
//  EditProfile.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import RxSwift

protocol EditProfile {
    func execute(request: ProfileEditRequest) -> Observable<Void>
}

final class EditProfileUseCase: EditProfile {
    
    private let userInfoRepo: UserInfoRepo
    
    init(userInfoRepo: UserInfoRepo) {
        self.userInfoRepo = userInfoRepo
    }
    
    func execute(request: ProfileEditRequest) -> Observable<Void> {
        return self.userInfoRepo
            .editProfile(requestModel: request)
            .asObservable()
    }
}



