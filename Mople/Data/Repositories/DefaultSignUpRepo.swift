//
//  DefaultProfileRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class DefaultSignUpRepo: SignUpRepo {

    private let networkService: AppNetWorkService

    init(networkService: AppNetWorkService) {
        print(#function, #line, "LifeCycle Test DefaultSignUpRepo Created" )
        self.networkService = networkService
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultSignUpRepo Deinit" )
    }
    
    func getRandomNickname() -> Single<Data> {
        let endpoint = APIEndpoints.getRandomNickname()
        return networkService.basicRequest(endpoint: endpoint)
    }
    
    func signUp(nickname: String,
                imagePath: String?,
                socialAccountInfo: SocialAccountInfo) -> Single<Void> {
        let endpoint = APIEndpoints.executeSignUp(platform: socialAccountInfo.platform,
                                                  identityToken: socialAccountInfo.identityCode,
                                                  email: socialAccountInfo.email,
                                                  nickname: nickname,
                                                  imagePath: imagePath)
        
        return networkService.basicRequest(endpoint: endpoint)
            .map { KeyChainService.shared.saveToken($0) }
    }
}



