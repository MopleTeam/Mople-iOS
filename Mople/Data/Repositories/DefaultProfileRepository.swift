//
//  DefaultProfileRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class DefaultProfileRepository: ProfileRepository {

    private let networkService: AppNetWorkService

    
    init(networkService: AppNetWorkService) {
        self.networkService = networkService
    }
    
    func getRandomNickname() -> Single<Data> {
        return networkService.authenticatedRequest { () throws -> Endpoint<Data> in
            try APIEndpoints.getRandomNickname()
        }
    }
    
    func checkNickname(name: String) -> Single<Bool> {
        return networkService.authenticatedRequest { () throws -> Endpoint<Bool> in
            try APIEndpoints.checkNickname(name: name)
        }
    }
    
    func makeProfile(image: Data, nickname: String) -> Single<Void> {
        return networkService.authenticatedRequest { () throws -> Endpoint<Void> in
            try APIEndpoints.setupProfile(image: image, nickName: nickname)
        }
    }
}
