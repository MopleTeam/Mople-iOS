//
//  JoinMeet.swift
//  Mople
//
//  Created by CatSlave on 4/24/25.
//

import RxSwift

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
