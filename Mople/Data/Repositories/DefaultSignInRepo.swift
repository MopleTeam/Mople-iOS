//
//  DefaultLoginRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import RxSwift

final class DefaultSignInRepo: SignInRepo {
    
    private let networkService: AppNetworkService
    
    init(networkService: AppNetworkService) {
        print(#function, #line, "LifeCycle Test DefaultSignInRepo Created" )
        self.networkService = networkService
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultSignInRepo Deinit" )
    }
    
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
