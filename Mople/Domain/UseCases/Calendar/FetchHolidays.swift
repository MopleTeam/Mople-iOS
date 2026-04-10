//
//  FetchHolidays.swift
//  Mople
//
//  Created by CatSlave on 6/15/25.
//

import Foundation

protocol FetchHolidays {
    func execute(for year: Int) async throws -> [Holiday]
}

final class FetchHolidaysUseCase: FetchHolidays {

    private let repo: CalendarRepo

    init(repo: CalendarRepo) {
        self.repo = repo
    }

    func execute(for year: Int) async throws -> [Holiday] {
        let response = try await repo.fetchHolidays(for: year)
        return response.map { $0.toDomain() }
    }
}

// MARK: - Mock
#if DEV
final class MockFetchHolidaysUseCase: FetchHolidays {
    func execute(for year: Int) async throws -> [Holiday] {
        print("✅ [Mock] \(year)년 공휴일 목록 조회")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let mockHolidays: [Holiday] = [
            Holiday(title: "신정", date: formatter.date(from: "\(year)-01-01")),
            Holiday(title: "삼일절", date: formatter.date(from: "\(year)-03-01")),
            Holiday(title: "어린이날", date: formatter.date(from: "\(year)-05-05")),
            Holiday(title: "광복절", date: formatter.date(from: "\(year)-08-15")),
            Holiday(title: "추석", date: formatter.date(from: "\(year)-09-17")),
            Holiday(title: "개천절", date: formatter.date(from: "\(year)-10-03")),
            Holiday(title: "한글날", date: formatter.date(from: "\(year)-10-09")),
            Holiday(title: "크리스마스", date: formatter.date(from: "\(year)-12-25"))
        ]

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockHolidays
    }
}
#endif
