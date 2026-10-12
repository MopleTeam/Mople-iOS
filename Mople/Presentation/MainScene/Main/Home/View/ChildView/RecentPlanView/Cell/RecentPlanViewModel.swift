//
//  HomePlanViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import Domain

struct RecentPlanViewModel {
    let title: String?
    let meet: MeetSummary?
    let date: Date?
    let address: String?
    let addressTitle: String?
    let participantCount: Int
    let weather: Weather?
    let isCreator: Bool
    
    var participantCountString: String {
        return L10n.participantCount(participantCount)
    }
    
    var dateString: String? {
        return DateManager.toString(date: date, format: .full)
    }
    
    var fullAddress: String? {
        let addressArray = [address, addressTitle].compactMap { $0 }
        if addressArray.isEmpty {
            return "장소가 없어요"
        } else {
            return addressArray.joined(separator: " ")
        }
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
        self.isCreator = plan.isCreator
    }
}

