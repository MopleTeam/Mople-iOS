//
//  PlanMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

protocol FetchMemberList {
    func execute(type: MemberListType, cursor: String?) async throws -> Page<MemberInfo>
}

final class FetchMemberUseCase: FetchMemberList {

    private let memberListRepo: MemberRepo

    init(memberListRepo: MemberRepo) {
        self.memberListRepo = memberListRepo
    }

    func execute(type: MemberListType, cursor: String?) async throws -> Page<MemberInfo> {
        return try await memberListRepo.execute(type: type, nextCursor: cursor)
    }
}

final class MockFetchMemberUseCase: FetchMemberList {

    // 50명의 Mock 멤버 데이터
    private let mockMembers: [MemberInfo] = {
        let nicknames = ["김철수", "이영희", "박민수", "정지원", "최수연",
                        "강동원", "송혜교", "이민호", "전지현", "공유",
                        "배수지", "박서준", "아이유", "임시완", "수지",
                        "차은우", "김고은", "남주혁", "한지민", "박보검",
                        "조인성", "손예진", "현빈", "윤아", "태연",
                        "서현", "티파니", "써니", "효연", "유리",
                        "수영", "윤하", "정용화", "강하늘", "박형식",
                        "이종석", "김우빈", "이준기", "지창욱", "박신혜",
                        "한효주", "고아라", "문채원", "박민영", "이나영",
                        "송중기", "김수현", "유아인", "이병헌", "하정우"]

        return (1...50).map { index in
            let hasImage = index % 3 == 0  // 3의 배수만 이미지 있음
            return MemberInfo(
                memberId: index,
                nickname: nicknames[index - 1],
                imagePath: hasImage ? "https://objectstorage.ap-chuncheon-1.oraclecloud.com/p/DM5O7DY_rL9lLzkSZ8y5XLPszC4WryfnNknRnzSwDnyxbe-RcO0DnZ1ByA8k-ObB/n/ax1e8qojvktg/b/DY_BUCKET/o/profile/9693e3fe-a879-4808-b160-48e6dc715769.jpg" : nil
            )
        }
    }()

    func execute(type: MemberListType, cursor: String?) async throws -> Page<MemberInfo> {

        // cursor를 사용해서 시작 인덱스 결정 (페이징 제대로 구현)
        let startIndex = cursor.flatMap { Int($0) } ?? 0
        let pageSize = 10
        let endIndex = min(startIndex + pageSize, mockMembers.count)

        // 해당 페이지의 멤버만 반환 (중복 없이!)
        let contentToReturn = Array(mockMembers[startIndex..<endIndex])
        let hasNext = endIndex < mockMembers.count
        let nextCursor = hasNext ? "\(endIndex)" : nil

        let page = Page(
            totalCount: mockMembers.count,
            content: contentToReturn,
            info: PageInfo(nextCursor: nextCursor, hasNext: hasNext, size: pageSize)
        )

        print("📄 Mock 페이징: \(startIndex)~\(endIndex - 1)번 인덱스 반환 (총 \(contentToReturn.count)명) | cursor: \(cursor ?? "nil") → nextCursor: \(nextCursor ?? "nil")")

        // 3초 딜레이 시뮬레이션
        try await Task.sleep(nanoseconds: 3_000_000_000)
        return page
    }
}
