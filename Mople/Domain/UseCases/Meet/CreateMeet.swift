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

final class CreateMeetUseCase: CreateMeet {
    
    let imageUploadRepo: ImageUploadRepo
    let createMeetRepo: CreateMeetRepo
    
    init(imageUploadRepo: ImageUploadRepo,
         createMeetRepo: CreateMeetRepo) {
        self.imageUploadRepo = imageUploadRepo
        self.createMeetRepo = createMeetRepo
    }
    
    func createMeet(title: String,
                    image: UIImage?) -> Single<Meet> {
        return Single.deferred { [weak self] in
            guard let self else { return .error(AppError.unknownError) }
            
            do {
                let imageData = try Data.imageDataCompressed(uiImage: image)
                return self.uploadImage(imageData)
                    .flatMap { self.createMeetRepo.createMeet(.init(name: title,
                                                                    image: $0)) }
                    .map { $0.toDomain() }
            } catch {
                return .error(error)
            }
        }
    }
    
    private func uploadImage(_ data: Data?) -> Single<String?> {
        return Single.deferred { [weak self] in
            guard let self else { return .error(AppError.unknownError) }
            guard let data else { return .just(nil) }
            return self.imageUploadRepo.uploadImage(image: data, path: .meet)
        }
    }
}


