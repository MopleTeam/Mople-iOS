//
//  DefaultProfileRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class DefaultSignUpRepo: SignUpRepo {

    private let networkService: AppNetworkService

    init(networkService: AppNetworkService) {
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
    
    func signUp(requestModel: SignUpRequest) -> Single<Void> {
        let endpoint = APIEndpoints.executeSignUp(requestModel: requestModel)
        
        return networkService.basicRequest(endpoint: endpoint)
            .map {
                KeyChainService.shared.saveToken($0)
            }
    }
    
    func testSignUp(requestModel: SignUpRequest) -> Single<Void> {
        let endpoint = APIEndpoints.executeSignUp(requestModel: requestModel)
        
        return networkService.basicRequest(endpoint: endpoint)
            .map {
                KeyChainService.shared.saveToken($0)
            }
    }
}



