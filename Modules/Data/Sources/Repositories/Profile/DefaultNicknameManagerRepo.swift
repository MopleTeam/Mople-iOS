//
//  DefaultProfileRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import Domain

public final class DefaultNicknameManagerRepo: BaseRepositories, NicknameRepo {
    public func creationNickname() async throws -> Data {
        let endpoint = APIEndpoints.getRandomNickname()
        return try await networkService.basicRequest(endpoint: endpoint)
    }

    public func isNicknameExists(_ name: String) async throws -> Data {
        let endpoint = APIEndpoints.checkNickname(name)

        return try await networkService.basicRequest(endpoint: endpoint)
    }
}



