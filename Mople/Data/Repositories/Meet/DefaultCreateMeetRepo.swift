//
//  DefaultCreateMeetRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

final class DefaultCreateMeetRepo: BaseRepositories, CreateMeetRepo {
    func createMeet(_ meet: CreateMeetRequest) -> Single<MeetResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.createMeet(meet)
        }
    }
}
