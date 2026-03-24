//
//  EditMeet.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation
import RxSwift

protocol EditMeet {
    func execute(id: Int,
                 request: CreateMeetRequest) -> Observable<Meet>
}

final class EditMeetUseCase: EditMeet {
    
    let repo: MeetRepo
    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute(id: Int,
                 request: CreateMeetRequest) -> Observable<Meet> {
        return repo.editMeet(
            id: id,
            reqeust: request)
        .map { $0.toDomain() }
        .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockEditMeetUseCase: EditMeet {
    func execute(id: Int,
                 request: CreateMeetRequest) -> Observable<Meet> {
        print("✅ [Mock] 모임 수정 - meetId: \(id)")

        let mockMeet = Meet(
            isCreator: true,
            meetSummary: MeetSummary(id: id, name: "수정된 모임"),
            sinceDays: 30,
            creatorId: 1,
            memberCount: 5,
            firstPlanDate: nil
        )

        return Observable.just(mockMeet)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

    
    
