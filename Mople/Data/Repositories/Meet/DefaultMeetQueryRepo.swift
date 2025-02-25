//
//  DefaultFetchMeetListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultMeetQueryRepo: BaseRepositories, MeetQueryRepo {
    
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
}
