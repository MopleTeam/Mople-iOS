//
//  EditPlan.swift
//  Mople
//
//  Created by CatSlave on 1/31/25.
//

import Foundation

protocol EditPlan {
    func execute(request: PlanRequest) async throws -> Plan
}

final class EditPlanUseCase: EditPlan {
    let editPlanRepo: PlanRepo

    init(editPlanRepo: PlanRepo) {
        self.editPlanRepo = editPlanRepo
    }

    func execute(request: PlanRequest) async throws -> Plan {
        var plan = try await editPlanRepo.editPlan(request: request)
        plan.isCreator = true
        return plan
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockEditPlanUseCase: EditPlan {
    func execute(request: PlanRequest) async throws -> Plan {
        print("✅ [Mock] 일정 수정 요청")

        let mockPlan = Plan(
            id: Int.random(in: 100...999),
            creatorId: 1,
            title: "수정된 일정",
            date: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
            participationCount: 3,
            isParticipation: true,
            addressTitle: "서울 강남역",
            address: "서울특별시 강남구 강남대로 396",
            meet: MeetSummary(id: 1, name: "테니스 동호회"),
            location: Location(longitude: 127.027621, latitude: 37.497942),
            weather: nil,
            isCreator: true,
            commentCount: 2,
            description: "수정된 Mock 일정입니다."
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockPlan
    }
}
#endif
