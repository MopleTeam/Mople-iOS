//
//  FetchRecentMeeting.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import Foundation
import RxSwift

protocol FetchHomeData {
    func execute() -> Single<HomeData>
}

final class FetchHomeDataUseCase: FetchHomeData {
    let repo: PlanQueryRepo
    
    init(homeDataRepo: PlanQueryRepo) {
        self.repo = homeDataRepo
    }
    
    func execute() -> Single<HomeData> {
        return repo.fetchHomeData()
            .map { $0.toDomain() }
    }
}





