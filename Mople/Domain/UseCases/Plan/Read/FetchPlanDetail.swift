//
//  FetchPlanDetail.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//
import Foundation

protocol FetchPlanDetail {
    func execute(planId: Int) async throws -> Plan
}

final class FetchPlanDetailUseCase: FetchPlanDetail {

    private let repo: PlanRepo
    private let session: UserSessionProvider

    init(repo: PlanRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    func execute(planId: Int) async throws -> Plan {
        let response = try await repo.fetchPlanDetail(planId: planId)
        var verifyPlan = response.toDomain()
        verifyPlan.verifyCreator(self.session.currentUserId)
        return verifyPlan
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchPlanDetailUseCase: FetchPlanDetail {
    func execute(planId: Int) async throws -> Plan {
        print("✅ [Mock] 일정 상세 조회 - planId: \(planId)")

        let mockPlan = Plan(
            id: planId,
            creatorId: 1,
            title: "주말 테니스 모임",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            participationCount: 5,
            isParticipation: true,
            addressTitle: "올림픽공원 테니스장",
            address: "서울특별시 송파구 올림픽로 424",
            meet: MeetSummary(id: 1, name: "테니스 동호회"),
            location: Location(longitude: 127.115921, latitude: 37.520407),
            weather: Weather(address: "송파구", imagePath: nil, temperature: 18.5, pop: 0.1),
            isCreator: true,
            commentCount: 3,
            description: "주말에 테니스 치러 갑시다!"
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockPlan
    }
}
#endif
