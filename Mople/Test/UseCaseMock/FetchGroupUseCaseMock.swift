//
//  FetchGroupUseCaseMock.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import RxSwift

final class fetchMeetUseCaseMock: FetchMeetUseCase {
    func fetchMeet(meetId: Int) -> Single<Meet> {
        return Observable.just(.mock(id: meetId, creatorId: 10))
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}



