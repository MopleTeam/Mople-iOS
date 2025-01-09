//
//  FetchGroup.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import RxSwift

protocol FetchMeetDetail {
    func fetchMeetDetail(meetId: Int) -> Single<Meet>
}

final class FetchMeetDetailUseCase: FetchMeetDetail {
   
    let meetDetailRepo: MeetDetailRepo
    
    init(meetDetailRepo: MeetDetailRepo) {
        self.meetDetailRepo = meetDetailRepo
    }
    
    func fetchMeetDetail(meetId: Int) -> Single<Meet> {
        return meetDetailRepo.fetchMeetDetail(meetId: meetId)
            .map { $0.toDomain()  }
    }
}
