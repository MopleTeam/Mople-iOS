//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import UIKit
import RxSwift

protocol CreateMeet {
    func createMeet(title: String, image: UIImage?) -> Single<Void>
}

final class CreateGroupImpl: CreateMeet {
    
    let imageUploadRepo: ImageUploadRepo
    let createMeetRepo: CreateMeetRepo
    
    init(imageUploadRepo: ImageUploadRepo,
         createMeetRepo: CreateMeetRepo) {
        self.imageUploadRepo = imageUploadRepo
        self.createMeetRepo = createMeetRepo
    }
    
    func createMeet(title: String, image: UIImage?) -> Single<Void> {
        
        let imageData = self.convertImageToData(image)
        return self.uploadImage(imageData)
            .map { $0.isEmpty ? nil : $0 }
            .flatMap { self.createMeetRepo.createMeet(title: title, imagePath: $0) }
    }
    
    private func uploadImage(_ data: Data?) -> Single<String> {
        return Single.deferred {
            guard let data else {
                return .just("")
            }
            
            return self.imageUploadRepo.uploadImage(image: data, path: .meet)
                .map { String(data: $0, encoding: .utf8) ?? "" }
        }
    }
    
    private func convertImageToData(_ image: UIImage?, quality: CGFloat = 0.3) -> Data? {
        return image?.jpegData(compressionQuality: quality)
    }
}
