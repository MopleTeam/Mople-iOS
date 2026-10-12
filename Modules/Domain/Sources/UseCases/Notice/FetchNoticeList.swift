//
//  FetchNoticeList.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

public protocol FetchNoticeList {
    // type: 공지 종류 필터. nil이면 전체, .custom/.system이면 해당 종류만 서버에서 걸러 받는다.
    func execute(meetId: Int,
                 type: NoticeType?,
                 size: Int?,
                 cursor: String?) async throws -> Page<Notice>
}

public final class FetchNoticeListUseCase: FetchNoticeList {

    private let repo: NoticeRepo

    public init(repo: NoticeRepo) {
        self.repo = repo
    }

    public func execute(meetId: Int,
                        type: NoticeType?,
                        size: Int?,
                        cursor: String?) async throws -> Page<Notice> {
        return try await repo.fetchNoticeList(meetId: meetId,
                                              type: type,
                                              size: size,
                                              cursor: cursor)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockFetchNoticeListUseCase: FetchNoticeList {
    public init() {}

    // 페이징/필터 테스트용 데이터셋 크기
    private static let mockCustomCount = 30   // 모임공지 30개
    private static let mockSystemCount = 15   // 시스템 공지 15개

    public func execute(meetId: Int,
                        type: NoticeType?,
                        size: Int?,
                        cursor: String?) async throws -> Page<Notice> {
        print("✅ [Mock] FetchNoticeList - meetId: \(meetId), type: \(type?.rawValue ?? "ALL"), size: \(size ?? -1), cursor: \(cursor ?? "nil")")

        // 1) 전체 데이터셋 구성 (모임공지 + 시스템). index가 작을수록 최신(상단).
        let now = Date()
        var all: [Notice] = []
        for index in 1...Self.mockCustomCount {
            all.append(Notice(
                noticeId: index,
                version: 1,
                meetId: meetId,
                type: .custom,
                content: "[모임공지 #\(index)] 11/28일 모임 18:00 → 20:00 변경되었습니다. 페이징 테스트용 공지입니다.",
                writer: UserInfo(id: 1, name: "모임장 매튜", imagePath: nil),
                isPinned: index == 1,   // 첫 번째만 고정
                createdAt: now.addingTimeInterval(Double(-index) * 3600)
            ))
        }
        for offset in 1...Self.mockSystemCount {
            let index = Self.mockCustomCount + offset
            all.append(Notice(
                noticeId: index,
                version: 1,
                meetId: meetId,
                type: .system,
                content: "[시스템 공지 #\(offset)] 새 멤버가 참여했어요.",
                isPinned: false,
                createdAt: now.addingTimeInterval(Double(-index) * 3600)
            ))
        }

        // 2) 서버 필터링 모사: type이 지정되면 해당 종류만
        let filtered: [Notice]
        if let type {
            filtered = all.filter { $0.type == type }
        } else {
            filtered = all
        }

        // 3) 커서 기반 페이지네이션 모사
        //    - cursor는 "다음 시작 오프셋"을 문자열로 인코딩 (nil/"" = 0부터)
        //    - size 미지정 시 15개씩
        let pageSize = size ?? 15
        let start = Int(cursor ?? "") ?? 0
        let end = min(start + pageSize, filtered.count)
        let pageContent = (start < end) ? Array(filtered[start..<end]) : []
        let hasNext = end < filtered.count
        let nextCursor = hasNext ? String(end) : nil

        try await Task.sleep(nanoseconds: 400_000_000)
        return Page(totalCount: filtered.count,
                    content: pageContent,
                    info: PageInfo(nextCursor: nextCursor, hasNext: hasNext, size: pageSize))
    }
}
#endif
