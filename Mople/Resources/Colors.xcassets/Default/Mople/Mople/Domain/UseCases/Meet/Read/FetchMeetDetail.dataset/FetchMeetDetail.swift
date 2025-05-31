//
//  FetchGroup.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import RxSwift

protocol FetchMeetDetail {
    func execute(meetId: Int) -> Observable<Meet>
}

final class FetchMeetDetailUseCase: FetchMeetDetail {
   
    private let repo: MeetRepo
    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute(meetId: Int) -> Observable<Meet> {
        return repo.fetchMeetDetail(meetId: meetId)
            .map { $0.toDomain()  }
            .asObservable()
    }
}
