//
//  DefaultCreateMeetRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

final class DefaultMeetRepo: BaseRepositories, MeetRepo {
    
    func fetchMeetList() -> Single<[MeetResponse]> {
        return self.networkService.authenticatedRequest(endpointClosure:
                                                            APIEndpoints.fetchMeetList
        )
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
}
