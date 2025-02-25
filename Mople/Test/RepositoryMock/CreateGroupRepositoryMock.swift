//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

final class CreateGroupRepositoryMock: MeetCommandRepo {
    func createMeet(reqeust: CreateMeetRequest) -> Single<MeetResponse> {
        return .just(.init(meetId: 999,
                           meetName: "테스트",
                           meetImage: nil,
                           sinceDays: 0,
                           creatorId: 999,
                           memberCount: 1,
                           lastPlanDay: nil))
    }
    
    func editMeet(id: Int, reqeust: CreateMeetRequest) -> RxSwift.Single<MeetResponse> {
        return .just(.init(meetId: 999,
                           meetName: "테스트",
                           meetImage: nil,
                           sinceDays: 0,
                           creatorId: 999,
                           memberCount: 1,
                           lastPlanDay: nil))
    }
    
    func deleteMeet(id: Int) -> Single<Void> {
        return .just(())
    }
    
    func leaveMeet(id: Int) -> Single<Void> {
        return .just(())
    }
}
