//
//  LeaveMeet.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation
import RxSwift

protocol LeaveMeet {
    func execute(id: Int) -> Single<Void>
}

final class LeaveMeetUseCase: LeaveMeet {
    let repo: MeetCommandRepo
    
    init(repo: MeetCommandRepo) {
 
        self.repo = repo   }
    
    func execute(id: Int) -> Single<Void> {
        return repo.leaveMeet(id: id)
    }
}
