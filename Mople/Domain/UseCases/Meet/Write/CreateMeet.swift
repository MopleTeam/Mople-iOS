//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

protocol CreateMeet {
    func execute(requset: CreateMeetRequest) -> Observable<Meet>
}

final class CreateMeetUseCase: CreateMeet {
    
    let createMeetRepo: MeetRepo
    
    init(createMeetRepo: MeetRepo) {
        self.createMeetRepo = createMeetRepo
    }
    
    func execute(requset: CreateMeetRequest) -> Observable<Meet> {
        return self.createMeetRepo
            .createMeet(reqeust: requset)
            .map { $0.toDomain() }
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockCreateMeetUseCase: CreateMeet {
    func execute(requset: CreateMeetRequest) -> Observable<Meet> {
        print("✅ [Mock] 모임 생성 요청")

        let mockMeet = Meet(
            meetSummary: MeetSummary(id: Int.random(in: 100...999), name: "새로운 모임"),
            sinceDays: 0,
            creatorId: 1,
            memberCount: 1,
            firstPlanDate: nil
        )

        return Observable.just(mockMeet)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
