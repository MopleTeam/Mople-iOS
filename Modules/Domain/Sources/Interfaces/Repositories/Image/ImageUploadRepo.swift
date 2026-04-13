//
//  ImageUploadRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation

public protocol ImageUploadRepo {
    func uploadImage(data: Data, path: ImageUploadPath) async throws -> String
    func uploadReviewImages(id: Int,
                            images: [Data]) async throws
}

