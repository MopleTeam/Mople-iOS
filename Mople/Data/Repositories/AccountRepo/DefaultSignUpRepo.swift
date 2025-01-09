//
//  DefaultProfileRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class DefaultSignUpRepo: BaseRepositories, SignUpRepo {
    func getRandomNickname() -> Single<Data> {
        let endpoint = APIEndpoints.getRandomNickname()
        return networkService.basicRequest(endpoint: endpoint)
    }
    
    func signUp(requestModel: SignUpRequest) -> Single<Void> {
        let endpoint = APIEndpoints.executeSignUp(requestModel: requestModel)
        
        return networkService.basicRequest(endpoint: endpoint)
            .map {
                KeyChainService.shared.saveToken($0)
            }
    }
}



