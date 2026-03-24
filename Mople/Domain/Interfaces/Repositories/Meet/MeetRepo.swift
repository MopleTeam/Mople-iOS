//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import RxSwift

protocol MeetRepo {
    func fetchMeetPage(cursor: String?) -> Single<PageResponse<MeetResponse>>
    func fetchMeetDetail(meetId: Int) -> Single<MeetResponse>
    func createMeet(reqeust: CreateMeetRequest) -> Single<MeetResponse>
    func editMeet(id: Int,
                  reqeust: CreateMeetRequest) -> Single<MeetResponse>
    func deleteMeet(id: Int) -> Single<Void>
    func transferMeet(meetId: Int, newHostId: Int) -> Single<Void>
    func fetchMyHostMeets(cursor: String?) -> Single<PageResponse<MeetResponse>>
    func inviteMeet(id: Int) -> Single<String>
    func joinMeet(code: String) -> Single<MeetResponse>
}
