//
//  FetchGroup.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import RxSwift

protocol FetchMeetDetail {
    func execute(meetId: Int) -> Single<Meet>
}

final class FetchMeetDetailUseCase: FetchMeetDetail {
   
    let meetDetailRepo: MeetQueryRepo
    
    init(meetDetailRepo: MeetQueryRepo) {
        self.meetDetailRepo = meetDetailRepo
    }
    
    func execute(meetId: Int) -> Single<Meet> {
        return meetDetailRepo.fetchMeetDetail(meetId: meetId)
            .map { $0.toDomain()  }
    }
}
