//
//  FetchMyHostMeets.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import Foundation

public protocol FetchMyHostMeets {
    func execute(cursor: String?) async throws -> Page<Meet>
}

// MARK: - Real UseCase
public final class FetchMyHostMeetsUseCase: FetchMyHostMeets {

    private let repo: MeetRepo

    public init(repo: MeetRepo) {
        self.repo = repo
    }

    public func execute(cursor: String?) async throws -> Page<Meet> {
        return try await repo.fetchMyHostMeets(cursor: cursor)
    }
}

// MARK: - Mock UseCase (테스트용)
public final class MockFetchMyHostMeetsUseCase: FetchMyHostMeets {
    public init() {}

    // 50개의 Mock 모임 데이터
    private let mockMeets: [Meet] = {
        let meetNames = [
            "테니스 동호회", "독서 모임", "등산 클럽", "요가 수업", "게임 모임",
            "사진 동호회", "맛집 탐방", "영화 감상", "음악 감상", "미술 감상",
            "축구 동호회", "배드민턴", "자전거 라이딩", "러닝 크루", "수영 모임",
            "볼링 동호회", "탁구 클럽", "배구 동호회", "농구 동호회", "야구 동호회",
            "와인 모임", "커피 스터디", "베이킹 클래스", "요리 모임", "칵테일 클럽",
            "외국어 스터디", "프로그래밍", "디자인 스터디", "투자 스터디", "마케팅 모임",
            "창업 모임", "부동산 스터디", "여행 동호회", "캠핑 클럽", "낚시 동호회",
            "드론 비행", "모형 제작", "목공예", "도자기 공방", "캘리그라피",
            "보드게임", "댄스 동호회", "트레킹 모임", "스키 동호회", "서핑 클럽",
            "클라이밍", "필라테스", "크로스핏", "헬스 모임", "명상 클럽"
        ]

        let calendar = Calendar.current
        let currentDate = Date()

        return (1...50).map { index in
            let hasPlan = index % 3 != 0  // 3의 배수가 아닌 경우 일정 있음
            let memberCount = (index % 5) + 2  // 2~6명
            let daysAgo = index * 3  // 각각 다른 since days

            return Meet(
                meetSummary: MeetSummary(id: index, name: meetNames[index - 1]),
                sinceDays: daysAgo,
                creatorId: 1, // Mock 사용자 ID
                memberCount: memberCount,
                firstPlanDate: hasPlan ? calendar.date(byAdding: .day, value: (index % 7) + 1, to: currentDate) : nil
            )
        }
    }()

    public func execute(cursor: String?) async throws -> Page<Meet> {

        // cursor를 사용해서 시작 인덱스 결정 (페이징 제대로 구현)
        let startIndex = cursor.flatMap { Int($0) } ?? 0
        let pageSize = 10
        let endIndex = min(startIndex + pageSize, mockMeets.count)

        // 해당 페이지의 모임만 반환 (중복 없이!)
        let contentToReturn = Array(mockMeets[startIndex..<endIndex])
        let hasNext = endIndex < mockMeets.count
        let nextCursor = hasNext ? "\(endIndex)" : nil

        let page = Page(
            totalCount: mockMeets.count,
            content: contentToReturn,
            info: PageInfo(nextCursor: nextCursor, hasNext: hasNext, size: pageSize)
        )

        print("📄 Mock 페이징: \(startIndex)~\(endIndex - 1)번 인덱스 반환 (총 \(contentToReturn.count)개) | cursor: \(cursor ?? "nil") → nextCursor: \(nextCursor ?? "nil")")

        // 3초 딜레이 시뮬레이션
        try await Task.sleep(nanoseconds: 3_000_000_000)
        return page
    }
}
