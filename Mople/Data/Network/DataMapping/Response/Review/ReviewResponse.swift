//
//  ReviewResponse.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

struct ReviewResponse: Decodable {
    var meetId: Int?
    var reviewId: Int?
    var postId: Int?
    var creatorId: Int?
    var reviewName: String?
    var address: String?
    var title: String?
    var reviewDateTime: String?
    var meetName: String?
    var meetImage: String?
    var lat: Double?
    var lot: Double?
    var participantsCount: Int?
    var images: [String]?
}

extension ReviewResponse {
    func toDomain() -> Review {
        let date = DateManager.parseServerDate(string: self.reviewDateTime)
        
        return .init(creatorId: creatorId,
                     id: reviewId,
                     name: reviewName,
                     date: date,
                     participantsCount: participantsCount,
                     address: address,
                     addressTitle: title,
                     images: images ?? [],
                     meet: .init(id: meetId,
                                 name: meetName,
                                 imagePath: meetImage),
                     location: .init(longitude: lot,
                                     latitude: lat))
    }
}
