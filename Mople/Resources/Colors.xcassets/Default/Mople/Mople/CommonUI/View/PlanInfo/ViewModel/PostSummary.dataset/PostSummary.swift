//
//  PostSummary.swift
//  Mople
//
//  Created by CatSlave on 5/11/25.
//

import Foundation

protocol PostSummary {
    var isCreator: Bool { get }
    var name: String? { get }
    var particiapantsCount: Int? { get }
    var date: Date? { get }
    var address: String? { get }
    var addressTitle: String? { get }
    var meet: MeetSummary? { get }
    var location: Location { get }
}

extension PostSummary {
    var participantsCountText: String? {
        guard let particiapantsCount else { return nil }
        return L10n.participantCount(particiapantsCount)
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

