//
//  ReviewImageResponse.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import Foundation

struct ReviewImageResponse: Decodable {
    var imageId: Int?
    var reviewImg: String?
}

extension ReviewImageResponse {
    func toDomain() -> ReviewImage {
        return .init(id: imageId,
                     path: reviewImg)
    }
}
