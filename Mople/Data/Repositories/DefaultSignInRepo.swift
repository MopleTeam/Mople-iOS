//
//  DefaultLoginRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import RxSwift

final class DefaultSignInRepo: SignInRepo {
    
    private let networkService: AppNetWorkService
    
    init(networkService: AppNetWorkService) {
        self.networkService = networkService
    }
    
    func signIn(socialAccountInfo: SocialAccountInfo) -> Single<Void> {
        let endpoint = APIEndpoints.executeSignIn(platform: socialAccountInfo.platform,
                                                   identityToken: socialAccountInfo.identityCode,
                                                   email: socialAccountInfo.email)
        
        return self.networkService.basicRequest(endpoint: endpoint)
            .map { token in
                KeyChainService.shared.saveToken(token)
            }
    }
}
