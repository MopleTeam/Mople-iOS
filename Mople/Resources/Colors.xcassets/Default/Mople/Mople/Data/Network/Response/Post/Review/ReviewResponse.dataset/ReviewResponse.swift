//
//  ReviewResponse.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

struct ReviewResponse: Decodable {
    let meetId: Int?
    let reviewId: Int?
    let postId: Int?
    let creatorId: Int?
    let reviewName: String?
    let address: String?
    let title: String?
    let reviewTime: String?
    let meetName: String?
    let meetImg: String?
    let lat: Double?
    let lot: Double?
    let participantsCount: Int?
    let images: [ReviewImageResponse]?
    let register: Bool?
}

extension ReviewResponse {
    func toDomain() -> Review {
        let date = DateManager.parseServerFullDate(string: self.reviewTime)
        let images = self.images?.compactMap({ $0.toDomain() })
        
        return .init(id: reviewId,
                     creatorId: creatorId,
                     postId: postId,
                     name: reviewName,
                     date: date,
                     participantsCount: participantsCount ?? 0,
                     address: address,
                     addressTitle: title,
                     images: images ?? [],
                     meet: .init(id: meetId,
                                 name: meetName,
                                 imagePath: meetImg),
                     location: .init(longitude: lot,
                                     latitude: lat),
                     isReviewd: register ?? false)
    }
}
