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
    
    func execute(_ image: UIImage?) -> Single<String?> {
        print(#function, #line)
        guard let image else { return .just(nil) }
        
        return Single.deferred { [weak self] in
            guard let self else { return .just(nil) }
            
            do {
                let imageData = try Data.imageDataCompressed(uiImage: image) 
                return self.imageUploadRepo.uploadImage(data: imageData, path: .profile)
            } catch {
                return .error(error)
            }
        }
    }
}
