//
//  FetchRecentMeeting.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import Foundation

public protocol FetchHomeData {
    func execute() async throws -> HomeData
}

public final class FetchHomeDataUseCase: FetchHomeData {
    private let repo: PlanRepo
    private let session: UserSessionProvider

    public init(repo: PlanRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    public func execute() async throws -> HomeData {
        var homeData = try await repo.fetchHomeData()
        verifyCreator(with: &homeData.plans)
        return homeData
    }

    private func verifyCreator(with planList: inout [Plan]) {
        planList.enumerated().forEach { index, plan in
            planList[index].verifyCreator(session.currentUserId)
        }
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockFetchHomeDataUseCase: FetchHomeData {
    public init() {}
    public func execute() async throws -> HomeData {
        print("✅ [Mock] 홈 데이터 조회")

        let calendar = Calendar.current
        let currentDate = Date()

        let mockPlans: [Plan] = (1...5).map { index in
            Plan(
                id: index,
                creatorId: index % 2 == 0 ? 1 : 99,
                title: ["테니스 모임", "독서 토론", "등산 계획", "맛집 탐방", "영화 관람"][index - 1],
                date: calendar.date(byAdding: .day, value: index, to: currentDate),
                participationCount: index + 1,
                isParticipation: index % 2 == 0,
                addressTitle: ["광화문", "강남역", "홍대입구", "잠실", "여의도"][index - 1],
                address: "서울특별시",
                meet: MeetSummary(id: index, name: "모임 \(index)"),
                location: Location(longitude: 126.976894, latitude: 37.575968),
                weather: Weather(address: "서울", imagePath: nil, temperature: 20.0, pop: 0.2),
                isCreator: index % 2 == 0,
                commentCount: index,
                description: "Mock 홈 일정 \(index)"
            )
        }

        let homeData = HomeData(plans: mockPlans, hasMeet: true)

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return homeData
    }
}
#endif
