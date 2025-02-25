//
//  ImageUploadRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

final class ImageUploadRepositoryMock: ImageUploadRepo {
    func uploadReviewImages(id: Int,
                            images: [Data]) -> Single<Void> {
        return Single.just(())
    }
    
    func uploadImage(data: Data, path: ImageUploadPath) -> Single<String?> {
        let photoPath = "https://picsum.photos/id/1/200/300"
        
//        return Single.just(photoPath.data(using: .utf8) ?? Data())
        return Single.just(photoPath)
    }
}
