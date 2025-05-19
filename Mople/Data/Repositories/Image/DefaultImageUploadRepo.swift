//
//  DefaultImageUploadRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import Foundation
import RxSwift

enum ImageUploadPath: String {
    case profile = "profile"
    case meet = "meet"
    case review = "review"
}

final class DefaultImageUploadRepo: BaseRepositories, ImageUploadRepo {
    func uploadImage(data: Data, path: ImageUploadPath) -> Single<String> {
        let imageUploadEndpoint = APIEndpoints.uploadImage(imageData: data,
                                                           folderPath: path)
        return networkService.basicRequest(endpoint: imageUploadEndpoint)
    }
    
    func uploadReviewImages(id: Int,
                            images: [Data]) -> Single<Void> {
        return networkService.authenticatedRequest {
            try APIEndpoints.uploadReviewImage(id: id, imageDatas: images)
        }
    }
}
