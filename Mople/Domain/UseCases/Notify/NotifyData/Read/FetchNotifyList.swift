//
//  FetchNotifyList.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import Foundation

protocol FetchNotifyList {
    func execute(cursor: String?) async throws -> Page<Notify>
}

final class FetchNotifyListUseCase: FetchNotifyList {

    private let repo: NotifyRepo

    init(repo: NotifyRepo) {
        self.repo = repo
    }

    func execute(cursor: String?) async throws -> Page<Notify> {
        let response = try await repo.fetchNotifyList(cursor: cursor)
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map({ $0.toDomain() }),
                    info: response.page?.toDomain())
    }
}

// MARK: - Mock
#if DEV
final class MockFetchNotifyListUseCase: FetchNotifyList {

    private let mockNotifications: [Notify] = {
        let calendar = Calendar.current
        let now = Date()

        return [
            Notify(id: 1,
                   meetImgPath: nil,
                   meetTitle: "테니스 동호회",
                   receiveDate: now,
                   type: .meet(id: 1),
                   message: "새로운 멤버가 모임에 참여했습니다.",
                   isRead: false),
            Notify(id: 2,
                   meetImgPath: nil,
                   meetTitle: "독서 모임",
                   receiveDate: calendar.date(byAdding: .hour, value: -2, to: now),
                   type: .plan(id: 1, date: calendar.date(byAdding: .day, value: 3, to: now)),
                   message: "새로운 일정이 등록되었습니다.",
                   isRead: false),
            Notify(id: 3,
                   meetImgPath: nil,
                   meetTitle: "등산 클럽",
                   receiveDate: calendar.date(byAdding: .day, value: -1, to: now),
                   type: .review(id: 1),
                   message: "새로운 후기가 등록되었습니다.",
                   isRead: true),
            Notify(id: 4,
                   meetImgPath: nil,
                   meetTitle: "맛집 탐방",
                   receiveDate: calendar.date(byAdding: .day, value: -2, to: now),
                   type: .plan(id: 2, date: calendar.date(byAdding: .day, value: 7, to: now)),
                   message: "일정이 수정되었습니다.",
                   isRead: true),
            Notify(id: 5,
                   meetImgPath: nil,
                   meetTitle: "게임 모임",
                   receiveDate: calendar.date(byAdding: .day, value: -3, to: now),
                   type: .meet(id: 2),
                   message: "모임 정보가 변경되었습니다.",
                   isRead: true)
        ]
    }()

    func execute(cursor: String?) async throws -> Page<Notify> {
        print("✅ [Mock] 알림 목록 조회 - cursor: \(cursor ?? "nil")")

        let startIndex = cursor.flatMap { Int($0) } ?? 0
        let pageSize = 3
        let endIndex = min(startIndex + pageSize, mockNotifications.count)
        let hasNext = endIndex < mockNotifications.count
        let content = Array(mockNotifications[startIndex..<endIndex])

        let page = Page<Notify>(
            totalCount: mockNotifications.count,
            content: content,
            info: PageInfo(nextCursor: hasNext ? "\(endIndex)" : nil,
                           hasNext: hasNext,
                           size: pageSize)
        )

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return page
    }
}
#endif
