//
//  ImageUpload.swift
//  Mople
//
//  Created by CatSlave on 1/18/25.
//

import UIKit

protocol ImageUpload {
    func execute(_ image: UIImage) async throws -> String
}

final class ImageUploadUseCase: ImageUpload {

    private let imageUploadRepo: ImageUploadRepo

    init(imageUploadRepo: ImageUploadRepo) {
        self.imageUploadRepo = imageUploadRepo
    }

    func execute(_ image: UIImage) async throws -> String {
        let imageData = try Data.imageDataCompressed(uiImage: image)
        return try await imageUploadRepo.uploadImage(data: imageData, path: .profile)
    }
}

// MARK: - Mock
#if DEV
final class MockImageUploadUseCase: ImageUpload {
    func execute(_ image: UIImage) async throws -> String {
        print("✅ [Mock] 이미지 업로드 - size: \(image.size)")
        let mockImageUrl = "https://mock-cdn.mople.com/images/profile_\(UUID().uuidString).jpg"
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockImageUrl
    }
}
#endif
