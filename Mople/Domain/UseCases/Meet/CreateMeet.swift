//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import UIKit
import RxSwift

protocol CreateMeet {
    func createMeet(title: String, image: UIImage?) -> Single<Meet>
}

final class CreateGroupUseCase: CreateMeet {
    
    let imageUploadRepo: ImageUploadRepo
    let createMeetRepo: CreateMeetRepo
    
    init(imageUploadRepo: ImageUploadRepo,
         createMeetRepo: CreateMeetRepo) {
        self.imageUploadRepo = imageUploadRepo
        self.createMeetRepo = createMeetRepo
    }
    
    func createMeet(title: String,
                    image: UIImage?) -> Single<Meet> {
        
        let imageData = self.convertImageToData(image)
        return self.uploadImage(imageData)
            .flatMap { self.createMeetRepo.createMeet(.init(name: title,
                                                            image: $0)) }
            .map { $0.toDomain() }
    }
    
    private func uploadImage(_ data: Data?) -> Single<String?> {
        return Single.deferred {
            guard let data else { return .just(nil) }
            
            return self.imageUploadRepo.uploadImage(image: data, path: .meet)
                .map { String(data: $0, encoding: .utf8) }
        }
    }
    
    private func convertImageToData(_ image: UIImage?, quality: CGFloat = 0.3) -> Data? {
        return image?.jpegData(compressionQuality: quality)
    }
}
