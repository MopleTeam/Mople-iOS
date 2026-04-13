//
//  EditProfile.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

protocol EditProfile {
    func execute(request: ProfileEditRequest) async throws
}

final class EditProfileUseCase: EditProfile {

    private let userInfoRepo: UserInfoRepo

    init(userInfoRepo: UserInfoRepo) {
        self.userInfoRepo = userInfoRepo
    }

    func execute(request: ProfileEditRequest) async throws {
        try await self.userInfoRepo
            .editProfile(requestModel: request)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockEditProfileUseCase: EditProfile {

    func execute(request: ProfileEditRequest) async throws {
        print("✅ [Mock] 프로필 수정 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 프로필 수정 성공")
    }
}
#endif
