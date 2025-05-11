//
//  PlanMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

protocol FetchMemberList {
    func execute(type: MemberListType) -> Observable<MemberList>
}

final class FetchMemberUseCase: FetchMemberList {
    
    private let memberListRepo: MemberRepo
    
    init(memberListRepo: MemberRepo) {
        self.memberListRepo = memberListRepo
    }
    
    func execute(type: MemberListType) -> Observable<MemberList> {
        return memberListRepo.execute(type: type)
            .map { $0.toDomain() }
            .asObservable()
            .flatMap { [weak self] members -> Observable<MemberList> in
                guard let self else { return .empty() }
                var memberList = members
                self.assignPosition(memberList: &memberList, type: type)
                return .just(memberList)
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



