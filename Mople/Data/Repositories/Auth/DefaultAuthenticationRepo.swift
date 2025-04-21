//
//  DefaultLoginRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import RxSwift

final class DefaultAuthenticationRepo: BaseRepositories, AuthenticationRepo {
    func signIn(social: SocialInfo) -> Single<Void> {
        let endpoint = APIEndpoints.signIn(platform: social.provider,
                                                  identityToken: social.token,
                                                  email: social.email)
        
        return self.networkService.basicRequest(endpoint: endpoint)
            .flatMap {
                JWTTokenStorage.shared.saveToken($0)
                return .just(())
            }
    }
    
    func signUp(requestModel: SignUpRequest) -> Single<Void> {
        let endpoint = APIEndpoints.signUp(request: requestModel)
        
        return networkService.basicRequest(endpoint: endpoint)
            .flatMap {
                JWTTokenStorage.shared.saveToken($0)
                return .just(())
            }
    }
    
    func signOut(userId: Int) -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.signOut(userId: userId)
        }
    }
    
    func deleteAccount() -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.deleteAccount()
        }
    }
}
