//
//  DefaultCreateMeetRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import Domain

public final class DefaultMeetRepo: BaseRepositories, MeetRepo {

    public func fetchMeetPage(cursor: String?) async throws -> Page<Meet> {
        let response: PageResponse<MeetResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetPage(cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    public func fetchMeetDetail(meetId: Int) async throws -> Meet {
        let response: MeetResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetDetail(id: meetId)
        }
        return response.toDomain()
    }

    public func createMeet(reqeust: CreateMeetRequest) async throws -> Meet {
        let dto = CreateMeetRequestDTO(request: reqeust)
        let response: MeetResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.createMeet(request: dto)
        }
        return response.toDomain()
    }

    public func editMeet(id: Int, reqeust: CreateMeetRequest) async throws -> Meet {
        let dto = CreateMeetRequestDTO(request: reqeust)
        let response: MeetResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.editMeet(id: id, request: dto)
        }
        return response.toDomain()
    }

    public func deleteMeet(id: Int) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.deleteMeet(id: id)
        }
    }

    public func transferMeet(meetId: Int, newHostId: Int) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.transferMeet(meetId: meetId, newHostId: newHostId)
        }
    }

    public func fetchMyHostMeets(cursor: String?) async throws -> Page<Meet> {
        let response: PageResponse<MeetResponse> = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchMyHostMeets(cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    public func inviteMeet(id: Int) async throws -> String {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.inviteMeet(id: id)
        }
    }

    public func joinMeet(code: String) async throws -> Meet {
        let response: MeetResponse = try await networkService.authenticatedRequest {
            try APIEndpoints.joinMeet(code: code)
        }
        return response.toDomain()
    }
}
