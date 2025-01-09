//
//  RecentPlanListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultRecentPlanListRepo: RecentPlanListRepo {

    private let networkServbice: AppNetworkService
    
    init(networkServbice: AppNetworkService) {
        print(#function, #line, "LifeCycle Test DefaultImageUploadRepo Created" )
        self.networkServbice = networkServbice
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultImageUploadRepo Deinit" )
    }
    
    func fetchRecentPlanList() -> Single<RecentPlanResponse> {
        networkServbice.authenticatedRequest(endpointClosure: APIEndpoints.fetchRecentPlan)
    }
}
