//
//  CalendarPlanViewModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

struct PostListViewModel {
    let title: String?
    let meet: MeetSummary?
    let participantCount: Int
    let weather: Weather?
    
    var participantCountString: String {        
        return L10n.participantCount(participantCount)
    }
}

extension PostListViewModel {
    init(post: MonthlyPost) {
        self.title = post.title
        self.meet = post.meet
        self.participantCount = post.memberCount
        self.weather = post.weather
    }
}
