//
//  DefaultCreateMeetRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation

final class DefaultMeetRepo: BaseRepositories, MeetRepo {

    func fetchMeetPage(cursor: String?) async throws -> Page<Meet> {
        let response: PageResponse<MeetResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetPage(cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    func fetchMeetDetail(meetId: Int) async throws -> Meet {
        let response: MeetResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetDetail(id: meetId)
        }
        return response.toDomain()
    }

    func createMeet(reqeust: CreateMeetRequest) async throws -> Meet {
        let response: MeetResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.createMeet(request: reqeust)
        }
        return response.toDomain()
    }

    func editMeet(id: Int, reqeust: CreateMeetRequest) async throws -> Meet {
        let response: MeetResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.editMeet(id: id, request: reqeust)
        }
        return response.toDomain()
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

    func fetchMyHostMeets(cursor: String?) async throws -> Page<Meet> {
        let response: PageResponse<MeetResponse> = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchMyHostMeets(cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    func inviteMeet(id: Int) async throws -> String {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.inviteMeet(id: id)
        }
    }

    func joinMeet(code: String) async throws -> Meet {
        let response: MeetResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.joinMeet(code: code)
        }
        return response.toDomain()
    }
}
