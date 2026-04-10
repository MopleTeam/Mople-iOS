//
//  DetailUserInfoRepo.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//
final class DefaultUserInfoRepo: BaseRepositories, UserInfoRepo {
    @MainActor
    func updateUserInfo() async throws {
        let userInfo = try await networkService.authenticatedRequest {
            try APIEndpoints.getUserInfo()
        }
        UserInfoStorage.shared.addEntity(userInfo.toDomain())
    }

    @MainActor
    func editProfile(requestModel: ProfileEditRequest) async throws {
        let profile = try await networkService.authenticatedRequest {
            try APIEndpoints.setupProfile(request: requestModel)
        }
        UserInfoStorage.shared.updateProfile(profile.toDomain())
    }
}

