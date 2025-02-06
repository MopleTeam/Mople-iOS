//
//  PlanMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

protocol FetchMemberList {
    func execute(type: MemberListType) -> Single<MemberList>
}

final class FetchMemberUseCase: FetchMemberList {
    
    private let memberListRepo: MemberListRepo
    
    init(memberListRepo: MemberListRepo) {
        self.memberListRepo = memberListRepo
    }
    
    func execute(type: MemberListType) -> Single<MemberList> {
        return memberListRepo.execute(type: type)
            .map { $0.toDomain() }
            .map { [weak self] in
                guard let self else { return $0 }
                var memberList = $0
                self.assignPosition(memberList: &memberList, type: type)
                return memberList
            }
    }
    
    private func assignPosition(memberList: inout MemberList, type: MemberListType) {
        guard let creatorId = memberList.creatorId,
              let createdMemberIndex = findCreatorIndex(members: memberList.membsers,
                                                        creatorId: creatorId) else { return }
        
        switch type {
        case .meet:
            memberList.membsers[createdMemberIndex].updatePosition(.owner)
        case .plan, .review:
            memberList.membsers[createdMemberIndex].updatePosition(.host)
        }
    }
    
    private func findCreatorIndex(members: [MemberInfo], creatorId: Int) -> Int? {
        return members.firstIndex {
            guard let id = $0.memberId else { return false }
            return id == creatorId
        }
    }
}



