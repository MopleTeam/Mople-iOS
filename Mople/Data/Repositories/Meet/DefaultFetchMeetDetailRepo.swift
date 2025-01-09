//
//  DefaultFetchMeetDetail.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultMeetDetailRepo: BaseRepositories, MeetDetailRepo {
    func fetchMeetDetail(meetId: Int) -> Single<MeetResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetDetail(meetId)
        }
    }
}
