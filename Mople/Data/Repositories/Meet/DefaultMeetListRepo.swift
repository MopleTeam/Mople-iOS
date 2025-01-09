//
//  DefaultFetchMeetListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultMeetListRepo: BaseRepositories, MeetListRepo {
    func fetchMeetList() -> Single<[MeetResponse]> {
        return self.networkService.authenticatedRequest(endpointClosure: APIEndpoints.fetchMeetList)
    }
}
