//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import RxSwift

protocol MeetCommandRepo {
    func createMeet(reqeust: CreateMeetRequest) -> Single<MeetResponse>
    func editMeet(id: Int,
                  reqeust: CreateMeetRequest) -> Single<MeetResponse>
    func deleteMeet(id: Int) -> Single<Void>
}
