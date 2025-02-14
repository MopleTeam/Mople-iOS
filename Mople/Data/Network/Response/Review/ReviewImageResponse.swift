//
//  ReviewImageResponse.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import Foundation

struct ReviewImageResponse: Decodable {
    var imageId: Int?
    var reviewImage: String?
}

extension ReviewImageResponse {
    func toDomain() -> ReviewImage {
        return .init(imageId: imageId,
                     reviewImage: reviewImage)
    }
}
