//
//  DefaultCalendarRepo.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import Domain

final class DefaultCalendarRepo: BaseRepositories, CalendarRepo {
    func fetchAllDates() async throws -> [Date] {
        let response: AllPlanDateResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchCalendarDates()
        }
        return response.toDomain().dates
    }

    func fetchHolidays(for year: Int) async throws -> [Holiday] {
        let response: [HolidayResponse] = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchHolidays(for: year)
        }
        return response.map { $0.toDomain() }
    }

    func fetchMonthlyPost(month: String) async throws -> [MonthlyPost] {
        let response: MonthlyPostResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchCalendarPagingData(month: month)
        }
        return response.toDomain()
    }
}
