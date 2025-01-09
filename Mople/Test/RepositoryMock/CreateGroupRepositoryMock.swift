//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

final class CreateGroupRepositoryMock: CreateMeetRepo {
    func createMeet(_ meet: CreateMeetRequest) -> Single<MeetResponse> {
        return .just(.init(meetId: 999,
                           meetName: "테스트",
                           meetImage: nil,
                           sinceDays: 0,
                           creatorId: 999,
                           memberCount: 1,
                           lastPlanDay: nil))
    }
}
