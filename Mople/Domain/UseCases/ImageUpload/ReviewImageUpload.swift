//
//  ReviewImageUpload.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import UIKit
import RxSwift

protocol ReviewImageUpload {
    func execute(id: Int,
                 images: [UIImage]) -> Single<Void>
}

final class ReviewImageUploadUseCase: ReviewImageUpload {
    
    private let repo: ImageUploadRepo
    
    init(repo: ImageUploadRepo) {
        self.repo = repo
    }
    
    func execute(id: Int,
                 images: [UIImage]) -> Single<Void> {
        return Single.deferred { [weak self] in
            guard let self else { return .never() }
            
            let datas = images.compactMap { [weak self] in
                self?.compressedImageData(uiImage: $0)
            }
            
            return repo.uploadReviewImages(id: id,
                                           images: datas)
        }
    }
    
    private func compressedImageData(uiImage: UIImage) -> Data? {
        return try? Data.imageDataCompressed(uiImage: uiImage)
    }
}
