//
//  FetchMeetFuturePlanUseCase.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

protocol FetchPlanPage {
    func execute(meetId: Int, cursor: String?) async throws -> Page<Plan>
}

final class FetchPlanPageUsecase: FetchPlanPage {
    private let repo: PlanRepo
    private let session: UserSessionProvider

    init(repo: PlanRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    func execute(meetId: Int, cursor: String?) async throws -> Page<Plan> {
        var page = try await repo.fetchPlanPage(meetId: meetId, cursor: cursor)
        verifyCreator(with: &page.content)
        return page
    }

    private func verifyCreator(with planList: inout [Plan]) {
        planList.enumerated().forEach { index, plan in
            guard let createId = plan.creatorId,
                  session.currentUserId == createId else { return }
            planList[index].isCreator = true
        }
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchPlanPageUseCase: FetchPlanPage {

    private let planTitles = [
        "주말 테니스", "독서 토론", "등산 계획", "요가 수업", "보드게임 대회",
        "사진 출사", "맛집 탐방", "영화 관람", "음악 공연", "미술 전시",
        "축구 경기", "배드민턴 대회", "자전거 라이딩", "러닝 모임", "수영 강습"
    ]

    func execute(meetId: Int, cursor: String?) async throws -> Page<Plan> {
        print("✅ [Mock] 모임 일정 목록 조회 - meetId: \(meetId), cursor: \(cursor ?? "nil")")

        let calendar = Calendar.current
        let currentDate = Date()
        let startIndex = cursor.flatMap { Int($0) } ?? 0
        let pageSize = 10
        let totalCount = planTitles.count
        let endIndex = min(startIndex + pageSize, totalCount)

        let plans: [Plan] = (startIndex..<endIndex).map { index in
            Plan(
                id: index + 1,
                creatorId: index % 2 == 0 ? 1 : 99,
                title: planTitles[index],
                date: calendar.date(byAdding: .day, value: index + 1, to: currentDate),
                participationCount: (index % 5) + 1,
                isParticipation: index % 3 == 0,
                addressTitle: "장소 \(index + 1)",
                address: "서울특별시 종로구",
                meet: MeetSummary(id: meetId, name: "모임 \(meetId)"),
                location: Location(longitude: 126.976894, latitude: 37.575968),
                weather: nil,
                isCreator: index % 2 == 0,
                commentCount: index % 4,
                description: "Mock 일정 \(index + 1)"
            )
        }

        let hasNext = endIndex < totalCount
        let nextCursor = hasNext ? "\(endIndex)" : nil

        let page = Page(
            totalCount: totalCount,
            content: plans,
            info: PageInfo(nextCursor: nextCursor, hasNext: hasNext, size: pageSize)
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return page
    }
}
#endif
