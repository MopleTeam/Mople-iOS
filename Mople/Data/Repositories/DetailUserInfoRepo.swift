//
//  DetailUserInfoRepo.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//
import RxSwift

final class DefaultUserInfoRepo: UserInfoRepo {
    
    private let networkService: AppNetworkService
    
    init(networkService: AppNetworkService) {
        print(#function, #line, "LifeCycle Test DefaultSignInRepo Created" )
        self.networkService = networkService
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultSignInRepo Deinit" )
    }
    
    func getUserInfo() -> Single<UserInfoDTO> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.getUserInfo()
        }
    }
}
