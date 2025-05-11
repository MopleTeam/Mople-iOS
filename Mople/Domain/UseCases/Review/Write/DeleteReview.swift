//
//  DeleteReview.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation
import RxSwift

protocol DeleteReview {
    func exectue(id: Int) -> Observable<Void>
}

final class DeleteReviewUseCase: DeleteReview {
    
    let repo: ReviewRepo
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func exectue(id: Int) -> Observable<Void> {
        return repo.deleteReview(id: id)
            .asObservable()
    }
}
