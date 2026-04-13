//
//  ValidativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

protocol CheckDuplicateNickname {
    func execute(_ nickname: String) async throws -> Bool
}

final class CheckDuplicateNicknameUseCase: CheckDuplicateNickname {

    private let duplicateCheckRepo: NicknameRepo

    init(duplicateCheckRepo: NicknameRepo) {
        self.duplicateCheckRepo = duplicateCheckRepo
    }

    func execute(_ nickname: String) async throws -> Bool {
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
final class MockCheckDuplicateNicknameUseCase: CheckDuplicateNickname {

    func execute(_ nickname: String) async throws -> Bool {
        print("✅ [Mock] 닉네임 중복 확인 요청 - nickname: \(nickname)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 닉네임 중복 확인 완료 - isDuplicate: false")
        return false
    }
}
#endif
