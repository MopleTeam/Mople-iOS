//
//  PostSummary.swift
//  Mople
//
//  Created by CatSlave on 5/11/25.
//

import Foundation
import Domain

protocol PostSummary {
    var postId: Int? { get }
    var isCreator: Bool { get }
    var name: String? { get }
    var particiapantsCount: Int? { get }
    var date: Date? { get }
    var address: String? { get }
    var addressTitle: String? { get }
    var meet: MeetSummary? { get }
    var location: Location? { get }
    var commentCount: Int { get }
    var description: String? { get }
}

// MARK: - PostSummary → PlaceInfo 변환
extension PlaceInfo {
    init(post: PostSummary) {
        self.init(
            title: post.addressTitle ?? L10n.nonName,
            address: nil,
            roadAddress: post.address,
            location: post.location
        )
    }
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
        let items = [address, addressTitle].compactMap { $0 } // nil 제거
        let result = items.joined(separator: " ")

        return result.isEmpty ? nil : result
    }
}

