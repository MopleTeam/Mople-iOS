//
//  CalendarRepo.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

protocol CalendarRepo {
    func fetchAllDates() async throws -> AllPlanDateResponse
    func fetchHolidays(for year: Int) async throws -> [HolidayResponse]
    func fetchMonthlyPost(month: String) async throws -> MonthlyPostResponse
}

