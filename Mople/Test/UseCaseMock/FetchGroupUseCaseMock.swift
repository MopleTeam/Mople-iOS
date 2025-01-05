//
//  FetchGroupUseCaseMock.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import RxSwift

final class fetchMeetUseCaseMock: FetchMeetUseCase {
    func fetchMeet(meetId: Int) -> Single<Meet> {
        return Observable.just(.mock(id: meetId))
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}



extension MeetSummary {
    static func mock(id: Int) -> MeetSummary {
        return .init(id: id,
                     name: "테스트 모임 \(id)",
                     imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300")
    }
}
