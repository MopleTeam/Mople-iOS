//
//  ReviewResponse.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

struct ReviewResponse: Decodable {
    var meetId: Int?
    var creatorId: Int?
    var meetName: String?
    var meetImage: String?
    var reviewId: Int?
    var reviewName: String?
    var reviewDateTime: String?
    var participantsCount: Int?
    var address: String?
    var lat: Double?
    var lot: Double?
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
                     images: images ?? [],
                     meet: .init(id: meetId,
                                 name: meetName,
                                 imagePath: meetImage),
                     location: .init(longitude: lot,
                                     latitude: lat))
    }
}
