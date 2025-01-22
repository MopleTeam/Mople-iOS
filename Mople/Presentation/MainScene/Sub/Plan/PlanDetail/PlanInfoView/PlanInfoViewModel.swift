//
//  PlanDetailViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import Foundation

struct PlanInfoViewModel {
    let name: String?
    let particiapantsCount: Int?
    let date: Date?
    let address: String?
    let addressTitle: String?
    let meet: MeetSummary?
    let location: Location?
    
    var participantsCountText: String? {
        guard let particiapantsCount else { return nil }
        return "\(particiapantsCount)명 참여"
    }
    
    var dateString: String? {
        guard let date else { return nil}
        return DateManager.toString(date: date, format: .full)
    }
    
    var fullAddress: String? {
        return [address, addressTitle]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
}

extension PlanInfoViewModel {
    init(plan: Plan) {
        self.name = plan.title
        self.particiapantsCount = plan.participantCount
        self.date = plan.date
        self.address = plan.address
        self.addressTitle = plan.addressTitle
        self.meet = plan.meet
        self.location = plan.location
    }
    
    #warning("타이틀 추가 필요")
    init(review: Review) {
        self.name = review.name
        self.particiapantsCount = review.participantsCount
        self.date = review.date
        self.address = review.address
        self.addressTitle = review.addressTitle
        self.meet = review.meet
        self.location = review.location
    }
}
