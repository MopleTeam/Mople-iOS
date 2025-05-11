//
//  DeleteMeet.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation
import RxSwift

protocol DeleteMeet {
    func execute(id: Int) -> Observable<Void>
}

final class DeleteMeetUseCase: DeleteMeet {
    
    let repo: MeetRepo
    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute(id: Int) -> Observable<Void> {
        return repo.deleteMeet(id: id)
            .asObservable()
    }
}
