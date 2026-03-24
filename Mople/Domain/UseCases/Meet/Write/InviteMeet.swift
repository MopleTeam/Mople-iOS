//
//  InviteMeet.swift
//  Mople
//
//  Created by CatSlave on 4/24/25.
//

import Foundation
import RxSwift

protocol InviteMeet {
    func execute(id: Int) -> Observable<String>
}

final class InviteMeetUseCase: InviteMeet {
    
    private let repo: MeetRepo
    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute(id: Int) -> Observable<String> {
        return repo.inviteMeet(id: id)
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockInviteMeetUseCase: InviteMeet {
    func execute(id: Int) -> Observable<String> {
        print("✅ [Mock] 모임 초대 코드 생성 - meetId: \(id)")

        let mockCode = "MOCK-\(id)-\(String(format: "%04d", Int.random(in: 1000...9999)))"

        return Observable.just(mockCode)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

