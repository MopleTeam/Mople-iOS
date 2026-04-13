//
//  CalendarRepo.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

protocol CalendarRepo {
    func fetchAllDates() async throws -> [Date]
    func fetchHolidays(for year: Int) async throws -> [Holiday]
    func fetchMonthlyPost(month: String) async throws -> [MonthlyPost]
}

