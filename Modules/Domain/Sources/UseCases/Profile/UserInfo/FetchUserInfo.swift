//
//  FetchUserInfo.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//
import Foundation

public protocol FetchUserInfo {
    func execute() async throws
}

public final class FetchUserInfoUseCase: FetchUserInfo {

    private let userInfoRepo: UserInfoRepo

    public init(userInfoRepo: UserInfoRepo) {
        self.userInfoRepo = userInfoRepo
    }

    public func execute() async throws {
        try await self.userInfoRepo.updateUserInfo()
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockFetchUserInfoUseCase: FetchUserInfo {
    public init() {}

    public func execute() async throws {
        print("✅ [Mock] 유저 정보 조회 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 유저 정보 조회 성공")
    }
}
#endif
