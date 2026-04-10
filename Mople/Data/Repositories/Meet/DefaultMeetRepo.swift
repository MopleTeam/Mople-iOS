//
//  DefaultCreateMeetRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation

final class DefaultMeetRepo: BaseRepositories, MeetRepo {

    func fetchMeetPage(cursor: String?) async throws -> PageResponse<MeetResponse> {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetPage(cursor: cursor)
        }
    }

    func fetchMeetDetail(meetId: Int) async throws -> MeetResponse {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetDetail(id: meetId)
        }
    }

    func createMeet(reqeust: CreateMeetRequest) async throws -> MeetResponse {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.createMeet(request: reqeust)
        }
    }

    func editMeet(id: Int,
                  reqeust: CreateMeetRequest) async throws -> MeetResponse {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.editMeet(id: id,
                                      request: reqeust)
        }
    }

    func deleteMeet(id: Int) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.deleteMeet(id: id)
        }
    }

    func transferMeet(meetId: Int, newHostId: Int) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.transferMeet(meetId: meetId, newHostId: newHostId)
        }
    }

    func fetchMyHostMeets(cursor: String?) async throws -> PageResponse<MeetResponse> {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchMyHostMeets(cursor: cursor)
        }
    }

    func inviteMeet(id: Int) async throws -> String {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.inviteMeet(id: id)
        }
    }

    func joinMeet(code: String) async throws -> MeetResponse {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.joinMeet(code: code)
        }
    }
}
