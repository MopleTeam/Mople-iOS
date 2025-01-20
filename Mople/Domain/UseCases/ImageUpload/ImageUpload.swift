//
//  ImageUpload.swift
//  Mople
//
//  Created by CatSlave on 1/18/25.
//

import UIKit
import RxSwift

protocol ImageUpload {
    func execute(_ image: UIImage?) -> Single<String?>
}

final class ImageUploadUseCase: ImageUpload {
    
    private let imageUploadRepo: ImageUploadRepo
    
    init(imageUploadRepo: ImageUploadRepo) {
        self.imageUploadRepo = imageUploadRepo
    }
    
    func execute(_ image: UIImage?) -> RxSwift.Single<String?> {
        return Single.deferred { [weak self] in
            guard let self else { return .error(AppError.unknownError) }
            
            do {
                guard let imageData = try Data.imageDataCompressed(uiImage: image) else {
                    return .just(nil)
                }
                return self.imageUploadRepo.uploadImage(image: imageData, path: .profile)
            } catch {
                return .error(error)
            }
        }
    }
}
