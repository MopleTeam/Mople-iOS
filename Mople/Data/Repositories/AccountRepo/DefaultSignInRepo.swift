//
//  DefaultLoginRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import RxSwift

final class DefaultSignInRepo: BaseRepositories, SignInRepo {
    func signIn(social: SocialInfo) -> Single<Void> {
        let endpoint = APIEndpoints.executeSignIn(platform: social.provider,
                                                  identityToken: social.token,
                                                  email: social.email)
        
        return self.networkService.basicRequest(endpoint: endpoint)
            .map {
                KeyChainService.shared.saveToken($0)
            }
    }
}
