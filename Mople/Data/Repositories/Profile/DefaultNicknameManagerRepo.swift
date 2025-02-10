//
//  DefaultProfileRepository.swift
//  Group
//
//  Created by CatSlave on 10/23/24.
//

import Foundation
import RxSwift

final class DefaultNicknameManagerRepo: BaseRepositories, NicknameRepo {
    func creationNickname() -> Single<Data> {
        let endpoint = APIEndpoints.getRandomNickname()
        return networkService.basicRequest(endpoint: endpoint)
    }
    
    func isNicknameExists(_ name: String) -> Single<Data> {
        let endpoint = APIEndpoints.checkNickname(name)
        
        return networkService.basicRequest(endpoint: endpoint)
    }
}



