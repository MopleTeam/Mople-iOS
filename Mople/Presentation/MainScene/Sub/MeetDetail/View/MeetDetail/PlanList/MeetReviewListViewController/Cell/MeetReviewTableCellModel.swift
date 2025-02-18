//
//  PastPlanTableViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import UIKit

struct MeetReviewTableCellModel {
    let title: String?
    let date: Date?
    let participantCount: Int?
    let imagePath: String?
    let imageCount: Int
    
    var dateString: String? {
        return DateManager.toString(date: date, format: .dot)
    }
    
    var participantCountString: String? {
        guard let participantCount = participantCount else { return nil }
        
        return "\(participantCount)명 참여"
    }
}

extension MeetReviewTableCellModel {
    init(review: Review) {
        self.title = review.name
        self.date = review.date
        self.participantCount = review.participantsCount
        self.imagePath = review.images.first?.path
        self.imageCount = review.images.count
    }
}
