//
//  HomePlanViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

struct RecentPlanViewModel {
    let title: String?
    let meet: MeetSummary?
    let date: Date?
    let address: String?
    let addressTitle: String?
    let participantCount: Int
    let weather: Weather?
    
    var participantCountString: String {
        return L10n.participantCount(participantCount)
    }
    
    var dateString: String? {
        return DateManager.toString(date: date, format: .full)
    }
    
    var fullAddress: String? {
        [address, addressTitle].compactMap { $0 }.joined(separator: " ")
    }
}

extension RecentPlanViewModel {
    init(plan: Plan) {
        self.title = plan.title
        self.meet = plan.meet
        self.date = plan.date
        self.address = plan.address
        self.addressTitle = plan.addressTitle
        self.participantCount = plan.participationCount
        self.weather = plan.weather
    }
}

