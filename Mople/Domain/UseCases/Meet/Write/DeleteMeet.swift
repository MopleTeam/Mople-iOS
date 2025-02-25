//
//  DeleteMeet.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation
import RxSwift

protocol DeleteMeet {
    func execute(id: Int) -> Single<Void>
}

final class DeleteMeetUseCase: DeleteMeet {
    
    let repo: MeetCommandRepo
    
    init(repo: MeetCommandRepo) {
        self.repo = repo
    }
    
    func execute(id: Int) -> Single<Void> {
        return repo.deleteMeet(id: id)
    }
}
