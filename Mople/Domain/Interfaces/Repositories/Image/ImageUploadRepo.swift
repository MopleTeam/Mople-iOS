//
//  ImageUploadRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

protocol ImageUploadRepo {
    func uploadImage(data: Data, path: ImageUploadPath) -> Single<String>
    func uploadReviewImages(id: Int,
                            images: [Data]) -> Single<Void>
}

