//
//  PlanDetailViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import Foundation

struct PlanDetailViewModel {
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
        return DateManager.toString(date: date, format: .dot)
    }
    
    var fullAddress: String? {
        [address, addressTitle].compactMap { $0 }.joined(separator: " ")
    }
    
}

extension PlanDetailViewModel {
    init(_ plan: Plan) {
        self.name = plan.title
        self.particiapantsCount = plan.participantCount
        self.date = plan.date
        self.address = plan.address
        self.addressTitle = plan.addressTitle
        self.meet = plan.meet
        self.location = plan.location
    }
}
