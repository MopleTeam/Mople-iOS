//
//  HomePlanViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

struct HomePlanCollectionCellViewModel {
    let title: String?
    let meet: MeetSummary?
    let date: Date?
    let address: String?
    let participantCount: Int?
    let weather: Weather?
    
    var participantCountString: String? {
        guard let participantCount = participantCount else { return nil }
        
        return "\(participantCount)명 참여"
    }
    
    var dateString: String? {
        return DateManager.toString(date: date, format: .full)
    }
}

extension HomePlanCollectionCellViewModel {
    init(plan: Plan) {
        self.title = plan.title
        self.meet = plan.meet
        self.date = plan.date
        self.address = plan.address
        self.participantCount = plan.participantCount
        self.weather = plan.weather
    }
}

