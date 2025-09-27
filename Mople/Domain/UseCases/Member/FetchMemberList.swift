//
//  PlanMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

protocol FetchMemberList {
    func execute(type: MemberListType, cursor: String?) -> Observable<Page<MemberInfo>>
}

final class FetchMemberUseCase: FetchMemberList {
    
    private let memberListRepo: MemberRepo
    
    init(memberListRepo: MemberRepo) {
        self.memberListRepo = memberListRepo
    }
    
    func execute(type: MemberListType, cursor: String?) -> Observable<Page<MemberInfo>> {
        return memberListRepo.execute(type: type, nextCursor: cursor)
            .asObservable()
            .map { Page(totalCount: $0.totalCount ?? 0,
                        content: $0.content.map({ $0.toDomain() }),
                        info: $0.page?.toDomain()) }
    }
}



