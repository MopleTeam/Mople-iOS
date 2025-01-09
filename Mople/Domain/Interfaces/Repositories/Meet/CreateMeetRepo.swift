//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import RxSwift

protocol CreateMeetRepo {
    func createMeet(_ meet: CreateMeetRequest) -> Single<MeetResponse>
}
