//
//  DetailUserInfoRepo.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//
import RxSwift

final class DefaultUserInfoRepo: BaseRepositories, UserInfoRepo {
    func getUserInfo() -> Single<Void> {
        let getUserInfo = networkService.authenticatedRequest {
            try APIEndpoints.getUserInfo()
        }
        
        return getUserInfo
            .observe(on: MainScheduler.instance)
            .flatMap({
                UserInfoStorage.shared.addEntity($0.toDomain())
                return .just(())
            })
    }
    
    func editProfile(requestModel: ProfileEditRequest) -> Single<Void> {
        let editProfile = networkService.authenticatedRequest {
            try APIEndpoints.setupProfile(requestModel: requestModel)
        }
        
        return editProfile
            .observe(on: MainScheduler.instance)
            .flatMap {
                UserInfoStorage.shared.updateProfile($0.toDomain())
                return .just(())
            }
    }
}

