//
//  CreatePlan.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

protocol CreatePlan {
    func execute(request: PlanRequest) async throws -> Plan
}

final class CreatePlanUseCase: CreatePlan {
    let createPlanRepo: PlanRepo

    init(createPlanRepo: PlanRepo) {
        self.createPlanRepo = createPlanRepo
    }

    func execute(request: PlanRequest) async throws -> Plan {
        var plan = try await createPlanRepo.createPlan(request: request)
        plan.isCreator = true
        return plan
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockCreatePlanUseCase: CreatePlan {
    func execute(request: PlanRequest) async throws -> Plan {
        print("✅ [Mock] 일정 생성 요청")

        let mockPlan = Plan(
            id: Int.random(in: 100...999),
            creatorId: 1,
            title: "새로운 일정",
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            participationCount: 1,
            isParticipation: true,
            addressTitle: "서울 광화문",
            address: "서울특별시 종로구 세종로 1-1",
            meet: MeetSummary(id: 1, name: "테니스 동호회"),
            location: Location(longitude: 126.976894, latitude: 37.575968),
            weather: nil,
            isCreator: true,
            commentCount: 0,
            description: "Mock 일정입니다."
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockPlan
    }
}
#endif
