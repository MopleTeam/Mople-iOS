//
//  ValidativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

public protocol CheckDuplicateNickname {
    func execute(_ nickname: String) async throws -> Bool
}

public final class CheckDuplicateNicknameUseCase: CheckDuplicateNickname {

    private let duplicateCheckRepo: NicknameRepo

    public init(duplicateCheckRepo: NicknameRepo) {
        self.duplicateCheckRepo = duplicateCheckRepo
    }

    public func execute(_ nickname: String) async throws -> Bool {
        let data = try await duplicateCheckRepo.isNicknameExists(nickname)
        let value = String(data: data, encoding: .utf8)
        return handleRequestValue(value)
    }

    private func handleRequestValue(_ value: String?) -> Bool {
        switch value {
        case "true": return true
        default: return false
        }
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockCheckDuplicateNicknameUseCase: CheckDuplicateNickname {
    public init() {}

    public func execute(_ nickname: String) async throws -> Bool {
        print("✅ [Mock] 닉네임 중복 확인 요청 - nickname: \(nickname)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 닉네임 중복 확인 완료 - isDuplicate: false")
        return false
    }
}
#endif
