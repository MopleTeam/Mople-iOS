//
//  PlanDetailViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import Foundation
import Domain

struct ReviewPostSummary: PostSummary {
    let postId: Int?
    let isCreator: Bool
    let name: String?
    let particiapantsCount: Int?
    let date: Date?
    let address: String?
    let addressTitle: String?
    let meet: MeetSummary?
    let location: Location?
    let isReviewd: Bool
    let images: [ReviewImage]
    var commentCount: Int
    var description: String?
    var hasImage: Bool { !images.isEmpty }
}

extension ReviewPostSummary {
    init(review: Review) {
        self.postId = review.postId
        self.isCreator = review.isCreator
        self.name = review.name
        self.particiapantsCount = review.participantsCount
        self.date = review.date
        self.address = review.address
        self.addressTitle = review.addressTitle
        self.meet = review.meet
        self.location = review.location
        self.isReviewd = review.isReviewd
        self.images = review.images
        self.commentCount = review.commentCount
        self.description = review.description
    }
}

