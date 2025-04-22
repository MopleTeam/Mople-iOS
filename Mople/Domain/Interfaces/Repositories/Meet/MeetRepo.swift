//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import RxSwift

protocol MeetRepo {
    func fetchMeetList() -> Single<[MeetResponse]>
    func fetchMeetDetail(meetId: Int) -> Single<MeetResponse>
    func createMeet(reqeust: CreateMeetRequest) -> Single<MeetResponse>
    func editMeet(id: Int,
                  reqeust: CreateMeetRequest) -> Single<MeetResponse>
    func deleteMeet(id: Int) -> Single<Void>
}
