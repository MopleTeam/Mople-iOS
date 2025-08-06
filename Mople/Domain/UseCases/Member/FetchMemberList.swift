//
//  PlanMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

protocol FetchMemberList {
    func execute(type: MemberListType, cursor: String?) -> Observable<MemberPage>
}

final class FetchMemberUseCase: FetchMemberList {
    
    private let memberListRepo: MemberRepo
    
    init(memberListRepo: MemberRepo) {
        self.memberListRepo = memberListRepo
    }
    
    func execute(type: MemberListType, cursor: String?) -> Observable<MemberPage> {
        return memberListRepo.execute(type: type, nextCursor: cursor)
            .asObservable()
            .map { $0.members.toDomain() }
    }
}



