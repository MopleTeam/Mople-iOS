//
//  FetchGroup.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import RxSwift
import Foundation

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

// MARK: - Mock UseCase
#if DEV
final class MockFetchMeetDetailUseCase: FetchMeetDetail {
    func execute(meetId: Int) -> Observable<Meet> {
        print("✅ [Mock] 모임 상세 조회 - meetId: \(meetId)")
        
        let userID = UserInfoStorage.shared.userInfo?.id

        let mockMeet = Meet(
            isCreator: true,
            meetSummary: MeetSummary(id: meetId, name: "테니스 동호회"),
            sinceDays: 120,
            creatorId: userID ?? 1,
            memberCount: 8,
            firstPlanDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
        )

        return Observable.just(mockMeet)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
