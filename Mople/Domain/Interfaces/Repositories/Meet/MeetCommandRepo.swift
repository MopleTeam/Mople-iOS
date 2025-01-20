//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import RxSwift

protocol MeetCommandRepo {
    func createMeet(_ meet: CreateMeetRequest) -> Single<MeetResponse>
}
