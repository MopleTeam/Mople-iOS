//
//  FetchCalendarPaingDate.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

public protocol FetchMonthlyPost {
    func execute(month: String) async throws -> [MonthlyPost]
}

public final class FetchMonthlyPostUseCase: FetchMonthlyPost {

    private let repo: CalendarRepo

    public init(repo: CalendarRepo) {
        self.repo = repo
    }

    public func execute(month: String) async throws -> [MonthlyPost] {
        return try await repo.fetchMonthlyPost(month: month)
    }
}

// MARK: - Mock
#if DEV
public final class MockFetchMonthlyPostUseCase: FetchMonthlyPost {
    public init() {}
    public func execute(month: String) async throws -> [MonthlyPost] {
        print("✅ [Mock] \(month) 월별 게시글 조회")

        let calendar = Calendar.current
        let today = Date()

        let mockPosts: [MonthlyPost] = [
            MonthlyPost(id: 1,
                        title: "강남역 모임",
                        date: today,
                        memberCount: 5,
                        meet: MeetSummary(id: 1, name: "테니스 동호회", imagePath: nil),
                        weather: Weather(address: "서울 강남구", imagePath: nil, temperature: 22.5, pop: 0.1),
                        type: .plan,
                        isCreator: true),
            MonthlyPost(id: 2,
                        title: "홍대 카페 투어",
                        date: calendar.date(byAdding: .day, value: 3, to: today),
                        memberCount: 3,
                        meet: MeetSummary(id: 2, name: "맛집 탐방", imagePath: nil),
                        weather: nil,
                        type: .plan,
                        isCreator: false),
            MonthlyPost(id: 3,
                        title: "북한산 등산 후기",
                        date: calendar.date(byAdding: .day, value: -2, to: today),
                        memberCount: 8,
                        meet: MeetSummary(id: 3, name: "등산 클럽", imagePath: nil),
                        weather: Weather(address: "서울 은평구", imagePath: nil, temperature: 18.0, pop: 0.3),
                        type: .review,
                        isCreator: false)
        ]

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockPosts
    }
}
#endif
