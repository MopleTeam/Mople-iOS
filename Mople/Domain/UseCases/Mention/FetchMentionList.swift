//
//  FetchMentionList.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

protocol FetchMentionList {
    func execute(meetId: Int, cursor: String?, keyword: String?) async throws -> Page<MemberInfo>
}

final class FetchMentionListUseCase: FetchMentionList {

    private let repo: MentionRepo

    init(repo: MentionRepo) {
        self.repo = repo
    }
    func execute(meetId: Int,
                 cursor: String?,
                 keyword: String?) async throws -> Page<MemberInfo> {

        let response = try await repo.execute(meetId: meetId,
                                               cursor: cursor,
                                               keyword: keyword)
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map({ $0.toDomain() }),
                    info: response.page?.toDomain())
    }
}

// MARK: - Mock
#if DEV
final class MockFetchMentionListUseCase: FetchMentionList {

    private let mockMembers: [MemberInfo] = [
        MemberInfo(memberId: 1, nickname: "김철수", imagePath: nil, position: .owner),
        MemberInfo(memberId: 2, nickname: "이영희", imagePath: nil, position: .host),
        MemberInfo(memberId: 3, nickname: "박민수", imagePath: nil, position: .member),
        MemberInfo(memberId: 4, nickname: "정수진", imagePath: nil, position: .member),
        MemberInfo(memberId: 5, nickname: "최동현", imagePath: nil, position: .member),
        MemberInfo(memberId: 6, nickname: "한지은", imagePath: nil, position: .member),
        MemberInfo(memberId: 7, nickname: "오승우", imagePath: nil, position: .member)
    ]

    func execute(meetId: Int, cursor: String?, keyword: String?) async throws -> Page<MemberInfo> {
        print("✅ [Mock] 멘션 멤버 목록 조회 - meetId: \(meetId), cursor: \(cursor ?? "nil"), keyword: \(keyword ?? "nil")")

        var filtered = mockMembers
        if let keyword, !keyword.isEmpty {
            filtered = mockMembers.filter { $0.nickname?.contains(keyword) == true }
        }

        let startIndex = cursor.flatMap { Int($0) } ?? 0
        let pageSize = 5
        let endIndex = min(startIndex + pageSize, filtered.count)
        let hasNext = endIndex < filtered.count
        let content = Array(filtered[startIndex..<endIndex])

        let page = Page<MemberInfo>(
            totalCount: filtered.count,
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
