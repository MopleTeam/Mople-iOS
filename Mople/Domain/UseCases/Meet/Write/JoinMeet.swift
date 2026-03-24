//
//  JoinMeet.swift
//  Mople
//
//  Created by CatSlave on 4/24/25.
//

import RxSwift
import Foundation

protocol JoinMeet {
    func execute(code: String) -> Observable<Meet>
}

final class JoinMeetUseCase: JoinMeet {
    private let repo: MeetRepo
    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute(code: String) -> Observable<Meet> {
        return repo.joinMeet(code: code)
            .map { $0.toDomain() }
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockJoinMeetUseCase: JoinMeet {
    func execute(code: String) -> Observable<Meet> {
        print("✅ [Mock] 모임 참여 - code: \(code)")

        let mockMeet = Meet(
            meetSummary: MeetSummary(id: Int.random(in: 100...999), name: "참여한 모임"),
            sinceDays: 0,
            creatorId: 99,
            memberCount: 4,
            firstPlanDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        )

        return Observable.just(mockMeet)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

