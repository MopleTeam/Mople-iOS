//
//  ImageUploadRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

final class ImageUploadRepositoryMock: ImageUploadRepository {
    func uploadImage(image: Data?) -> Single<String?> {
        return Single.just("https://picsum.photos/id/1/200/300")
    }
}
