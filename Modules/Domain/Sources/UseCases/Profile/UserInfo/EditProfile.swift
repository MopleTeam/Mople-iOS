//
//  EditProfile.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

public protocol EditProfile {
    func execute(request: ProfileEditRequest) async throws
}

public final class EditProfileUseCase: EditProfile {

    private let userInfoRepo: UserInfoRepo

    public init(userInfoRepo: UserInfoRepo) {
        self.userInfoRepo = userInfoRepo
    }

    public func execute(request: ProfileEditRequest) async throws {
        try await self.userInfoRepo
            .editProfile(requestModel: request)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockEditProfileUseCase: EditProfile {
    public init() {}

    public func execute(request: ProfileEditRequest) async throws {
        print("✅ [Mock] 프로필 수정 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 프로필 수정 성공")
    }
}
#endif
