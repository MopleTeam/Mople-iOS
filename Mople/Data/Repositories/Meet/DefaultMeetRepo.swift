//
//  DefaultCreateMeetRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

final class DefaultMeetRepo: BaseRepositories, MeetRepo {
    
    func fetchMeetPage(cursor: String?) -> Single<PageResponse<MeetResponse>> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetPage(cursor: cursor)
        }
    }
    
    func fetchMeetDetail(meetId: Int) -> Single<MeetResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetDetail(id: meetId)
        }
    }
    
    func createMeet(reqeust: CreateMeetRequest) -> Single<MeetResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.createMeet(request: reqeust)
        }
    }
    
    func editMeet(id: Int,
                  reqeust: CreateMeetRequest) -> Single<MeetResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.editMeet(id: id,
                                      request: reqeust)
        }
    }
    
    func deleteMeet(id: Int) -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.deleteMeet(id: id)
        }
    }
    
    func transferMeet(meetId: Int, newHostId: Int) -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.transferMeet(meetId: meetId, newHostId: newHostId)
        }
    }
    
    func fetchMyHostMeets(cursor: String?) -> Single<PageResponse<MeetResponse>> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchMyHostMeets(cursor: cursor)
        }
    }
    
    func inviteMeet(id: Int) -> Single<String> {
        return networkService.authenticatedRequest {
            try APIEndpoints.inviteMeet(id: id)
        }
    }
    
    func joinMeet(code: String) -> Single<MeetResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.joinMeet(code: code)
        }
    }
}
