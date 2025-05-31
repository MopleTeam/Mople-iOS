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

