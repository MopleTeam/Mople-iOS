//
//  FetchCalendarDates.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

protocol FetchAllPlanDate {
    func execute() async throws -> [Date]
}

final class FetchAllPlanDateUseCase: FetchAllPlanDate {

    private let repo: CalendarRepo

    init(repo: CalendarRepo) {
        self.repo = repo
    }

    func execute() async throws -> [Date] {
        return try await repo.fetchAllDates()
    }
}

// MARK: - Mock
#if DEV
final class MockFetchAllPlanDateUseCase: FetchAllPlanDate {
    func execute() async throws -> [Date] {
        print("✅ [Mock] 전체 일정 날짜 목록 조회")

        let calendar = Calendar.current
        let today = Date()
        let mockDates: [Date] = [
            today,
            calendar.date(byAdding: .day, value: 1, to: today)!,
            calendar.date(byAdding: .day, value: 3, to: today)!,
            calendar.date(byAdding: .day, value: 7, to: today)!,
            calendar.date(byAdding: .day, value: 14, to: today)!
        ]

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockDates
    }
}
#endif
