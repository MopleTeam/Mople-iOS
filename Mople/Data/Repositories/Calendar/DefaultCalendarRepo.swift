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
    
    func fetchHolidays(for year: Int) -> Single<[HolidayResponse]> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchHolidays(for: year)
        }
    }
    
    func fetchMonthlyPost(month: String) -> Single<MonthlyPostResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchCalendarPagingData(month: month)
        }
    }
}
