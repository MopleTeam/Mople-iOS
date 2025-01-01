//
//  DefaultNicknameValidationRepo.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//
import Foundation
import RxSwift

final class DefaultNicknameValidationRepo: NicknameValidationRepo {
    
    private let networkService: AppNetworkService
    
    init(networkService: AppNetworkService) {
        self.networkService = networkService
    }
    
    func isNicknameExists(_ name: String) -> Single<Data> {
        let endpoint = APIEndpoints.checkNickname(name)
        
        return networkService.basicRequest(endpoint: endpoint)
    }
}
