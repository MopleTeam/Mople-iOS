//
//  DefaultGroupRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import RxSwift

final class DefaultGroupRepository {
    
    private let dataTransferService: DataTransferService
    private let tokenKeyChainService: KeyChainService
    
    init(dataTransferService: DataTransferService,
         tokenKeyCahinService: KeyChainService) {
        self.dataTransferService = dataTransferService
        self.tokenKeyChainService = tokenKeyCahinService
    }
}

extension DefaultGroupRepository: UserRepository {
    func userLogin(authCode: String) -> Single<Void> {
        let endpoint = APIEndpoints.login(code: authCode)

        return Single.create { emitter in
            
            let task = self.dataTransferService.request(with: endpoint)
                .subscribe(with: self, onSuccess: { repo, token in
                    repo.tokenKeyChainService.saveToken(token)
                    emitter(.success(()))
                }, onFailure: { _, err in
                    emitter(.failure(err))
                })
            return task
        }
    }
}
