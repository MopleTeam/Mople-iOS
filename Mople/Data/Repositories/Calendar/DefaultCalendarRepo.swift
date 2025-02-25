//
//  DefaultCalendarRepo.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import RxSwift

final class DefaultCalendarRepo: BaseRepositories, CalendarRepo {
    func fetchAllDates() -> Single<AllPlanDateResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchCalendarDates()
        }
    }
    
    func fetchMonthlyPlan(month: String) -> Single<MonthlyPlanResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchCalendarPagingData(month: month)
        }
    }
}
