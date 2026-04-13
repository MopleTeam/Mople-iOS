//
//  FetchUserInfo.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//
import Foundation

protocol FetchUserInfo {
    func execute() async throws
}

final class FetchUserInfoUseCase: FetchUserInfo {

    private let userInfoRepo: UserInfoRepo

    init(userInfoRepo: UserInfoRepo) {
        self.userInfoRepo = userInfoRepo
    }

    func execute() async throws {
        try await self.userInfoRepo.updateUserInfo()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchUserInfoUseCase: FetchUserInfo {

    func execute() async throws {
        print("✅ [Mock] 유저 정보 조회 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 유저 정보 조회 성공")
    }
}
#endif
