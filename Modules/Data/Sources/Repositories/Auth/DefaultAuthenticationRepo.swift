//
//  DefaultLoginRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Domain

public final class DefaultAuthenticationRepo: BaseRepositories, AuthenticationRepo {
    public func signIn(social: SocialInfo) async throws {
        let endpoint = APIEndpoints.signIn(platform: social.provider,
                                                  identityToken: social.token,
                                                  email: social.email)

        let token = try await networkService.basicRequest(endpoint: endpoint)
        KeychainStorage.shared.saveToken(token)
    }

    public func signUp(requestModel: SignUpRequest) async throws {
        let dto = SignUpRequestDTO(request: requestModel)
        let endpoint = APIEndpoints.signUp(request: dto)

        let token = try await networkService.basicRequest(endpoint: endpoint)
        KeychainStorage.shared.saveToken(token)
    }

    public func signOut(userId: Int) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.signOut(userId: userId)
        }
    }

    public func deleteAccount() async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.deleteAccount()
        }
    }
}
