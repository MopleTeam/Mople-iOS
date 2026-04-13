//
//  GenerativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

public protocol CreationNickname {
    func executue() async throws -> String
}

public final class CreationNicknameUseCase: CreationNickname {

    let nickNameRepo: NicknameRepo

    public init(nickNameRepo: NicknameRepo) {
        self.nickNameRepo = nickNameRepo
    }

    public func executue() async throws -> String {
        let data = try await nickNameRepo.creationNickname()
        guard let nickname = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "CreationNickname", code: -1, userInfo: [NSLocalizedDescriptionKey: "닉네임 디코딩 실패"])
        }
        return nickname
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockCreationNicknameUseCase: CreationNickname {
    public init() {}

    public func executue() async throws -> String {
        print("✅ [Mock] 닉네임 생성 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 닉네임 생성 성공 - nickname: MockUser")
        return "MockUser"
    }
}
#endif
