//
//  ReviewCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import RxSwift

protocol ReviewCommandRepo {
    func deleteReviewImage(reviewId: Int, imageIds: [String]) -> Single<Void>
}
