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

// MARK: - Mock UseCase
#if DEV
final class MockEditProfileUseCase: EditProfile {

    func execute(request: ProfileEditRequest) -> Observable<Void> {
        print("✅ [Mock] 프로필 수정 요청")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print("✅ [Mock] 프로필 수정 성공") })
    }
}
#endif

