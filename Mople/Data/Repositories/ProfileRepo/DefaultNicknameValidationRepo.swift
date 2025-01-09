//
//  DefaultNicknameValidationRepo.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//
import Foundation
import RxSwift

final class DefaultNicknameValidationRepo:BaseRepositories,  NicknameValidationRepo {
    
    func isNicknameExists(_ name: String) -> Single<Data> {
        let endpoint = APIEndpoints.checkNickname(name)
        
        return networkService.basicRequest(endpoint: endpoint)
    }
}
