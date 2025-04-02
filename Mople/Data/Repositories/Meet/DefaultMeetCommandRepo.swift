//
//  DefaultCreateMeetRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

final class DefaultMeetCommandRepo: BaseRepositories, MeetCommandRepo {
    
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
