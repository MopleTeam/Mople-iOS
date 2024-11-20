//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

protocol CreateGroup {
    func createGroup(title: String, image: Data?) -> Single<Void>
}

final class CreateGroupImpl: CreateGroup {
    
    let imageUploadRepository: ImageUploadRepository
    let createGroupRepository: CreateGroupRepository
    
    init(imageUploadRepository: ImageUploadRepository,
         createGroupRepository: CreateGroupRepository) {
        self.imageUploadRepository = imageUploadRepository
        self.createGroupRepository = createGroupRepository
    }
    
    func createGroup(title: String, image: Data?) -> Single<Void> {
        return imageUploadRepository.uploadImage(image: image)
            .catch { err in
                return .just(nil)
            }
            .flatMap { imagePath in
                self.createGroupRepository.makeGroup(title: title, imagePath: imagePath)
            }
    }
}
