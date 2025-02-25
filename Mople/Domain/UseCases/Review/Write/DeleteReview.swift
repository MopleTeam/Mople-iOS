//
//  DeleteReview.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation
import RxSwift

protocol DeleteReview {
    func exectue(id: Int) -> Single<Void>
}

final class DeleteReviewUseCase: DeleteReview {
    
    let repo: ReviewCommandRepo
    
    init(repo: ReviewCommandRepo) {
        self.repo = repo
    }
    
    func exectue(id: Int) -> Single<Void> {
        return repo.deleteReview(id: id)
    }
}
