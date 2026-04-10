//
//  DefaultCalendarRepo.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

final class DefaultCalendarRepo: BaseRepositories, CalendarRepo {
    func fetchAllDates() async throws -> AllPlanDateResponse {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchCalendarDates()
        }
    }

    func fetchHolidays(for year: Int) async throws -> [HolidayResponse] {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchHolidays(for: year)
        }
    }

    func fetchMonthlyPost(month: String) async throws -> MonthlyPostResponse {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchCalendarPagingData(month: month)
        }
    }
}
