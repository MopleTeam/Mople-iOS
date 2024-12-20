//
//  PlanViewModel.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

// MARK: - ViewModel
struct PlanViewModel {
    let title: String?
    let date: Date?
    let meet: MeetSummary?
    let address: String?
    let participantCount: Int?
    let weather: Weather?
    
    var participantCountString: String? {
        guard let participantCount = participantCount else { return nil }
        
        return "\(participantCount)명 참여"
    }
    
    var dateString: String? {
        DateManager.toString(date: date, format: .full)
    }
}

extension PlanViewModel {
    init(plan: Plan) {
        self.title = plan.title
        self.date = plan.date
        self.meet = plan.meetngSummary
        self.address = plan.address
        self.participantCount = plan.participantCount
        self.weather = plan.weather
    }
}
