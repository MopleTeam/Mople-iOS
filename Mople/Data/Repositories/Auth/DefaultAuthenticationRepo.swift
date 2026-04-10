//
//  DefaultLoginRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

final class DefaultAuthenticationRepo: BaseRepositories, AuthenticationRepo {
    func signIn(social: SocialInfo) async throws {
        let endpoint = APIEndpoints.signIn(platform: social.provider,
                                                  identityToken: social.token,
                                                  email: social.email)

        let token = try await networkService.basicRequest(endpoint: endpoint)
        KeychainStorage.shared.saveToken(token)
    }

    func signUp(requestModel: SignUpRequest) async throws {
        let endpoint = APIEndpoints.signUp(request: requestModel)

        let token = try await networkService.basicRequest(endpoint: endpoint)
        KeychainStorage.shared.saveToken(token)
    }

    func signOut(userId: Int) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.signOut(userId: userId)
        }
    }

    func deleteAccount() async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.deleteAccount()
        }
    }
}
