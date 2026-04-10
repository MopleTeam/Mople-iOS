//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

protocol MeetRepo {
    func fetchMeetPage(cursor: String?) async throws -> Page<Meet>
    func fetchMeetDetail(meetId: Int) async throws -> Meet
    func createMeet(reqeust: CreateMeetRequest) async throws -> Meet
    func editMeet(id: Int, reqeust: CreateMeetRequest) async throws -> Meet
    func deleteMeet(id: Int) async throws
    func transferMeet(meetId: Int, newHostId: Int) async throws
    func fetchMyHostMeets(cursor: String?) async throws -> Page<Meet>
    func inviteMeet(id: Int) async throws -> String
    func joinMeet(code: String) async throws -> Meet
}
