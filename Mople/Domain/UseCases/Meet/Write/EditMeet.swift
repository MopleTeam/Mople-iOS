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
                 request: CreateMeetRequest) -> Single<Meet?>
}

final class EditMeetUseCase: EditMeet {
    
    let repo: MeetCommandRepo
    
    init(repo: MeetCommandRepo) {
        self.repo = repo
    }
    
    func execute(id: Int,
                 request: CreateMeetRequest) -> Single<Meet?> {
        return repo.editMeet(
            id: id,
            reqeust: request)
        .map { $0.toDomain() }
    }
}





    
    
