//
//  FetchHolidays.swift
//  Mople
//
//  Created by CatSlave on 6/15/25.
//

import Foundation

public protocol FetchHolidays {
    func execute(for year: Int) async throws -> [Holiday]
}

public final class FetchHolidaysUseCase: FetchHolidays {

    private let repo: CalendarRepo

    public init(repo: CalendarRepo) {
        self.repo = repo
    }

    public func execute(for year: Int) async throws -> [Holiday] {
        return try await repo.fetchHolidays(for: year)
    }
}

// MARK: - Mock
#if DEV
public final class MockFetchHolidaysUseCase: FetchHolidays {
    public init() {}
    public func execute(for year: Int) async throws -> [Holiday] {
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
