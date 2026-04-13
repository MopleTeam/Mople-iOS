//
//  DefaultImageUploadRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import Foundation
import Domain

final class DefaultImageUploadRepo: BaseRepositories, ImageUploadRepo {
    func uploadImage(data: Data, path: ImageUploadPath) async throws -> String {
        let imageUploadEndpoint = APIEndpoints.uploadImage(imageData: data,
                                                           folderPath: path)
        return try await networkService.basicRequest(endpoint: imageUploadEndpoint)
    }

    func uploadReviewImages(id: Int,
                            images: [Data]) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.uploadReviewImage(id: id, imageDatas: images)
        }
    }
}
