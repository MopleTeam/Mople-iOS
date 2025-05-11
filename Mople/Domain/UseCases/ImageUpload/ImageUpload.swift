//
//  ImageUpload.swift
//  Mople
//
//  Created by CatSlave on 1/18/25.
//

import UIKit
import RxSwift

protocol ImageUpload {
    func execute(_ image: UIImage) -> Observable<String>
}

final class ImageUploadUseCase: ImageUpload {
    
    private let imageUploadRepo: ImageUploadRepo
    
    init(imageUploadRepo: ImageUploadRepo) {
        self.imageUploadRepo = imageUploadRepo
    }
    
    func execute(_ image: UIImage) -> Observable<String> {
        return Observable.deferred { [weak self] in
            guard let self else { return .empty() }
            
            do {
                let imageData = try Data.imageDataCompressed(uiImage: image)
                return self.imageUploadRepo.uploadImage(data: imageData, path: .profile)
                    .asObservable()
            } catch {
                return .error(error)
            }
        }
    }
}
