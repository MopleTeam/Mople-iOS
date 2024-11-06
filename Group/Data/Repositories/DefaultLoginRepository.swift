//
//  DefaultLoginRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class DefaultLoginRepository: LoginRepository {
    
    private let networkService: AppNetWorkService
    
    init(networkService: AppNetWorkService) {
        self.networkService = networkService
    }
    
    func userLogin(platForm: LoginPlatform, authCode: String) -> Single<Void> {
        let endpoint = APIEndpoints.executeSignUp(platform: platForm, code: authCode)
        
        return Single.create { emitter in
            
            return self.networkService.basicRequest(endpoint: endpoint)
                .subscribe(with: self) { repo, token in
                    KeyChainService.shared.saveToken(token)
                    emitter(.success(()))
                } onFailure: { _, err in
                    emitter(.failure(err))
                }
        }
    }
}
