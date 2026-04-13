//
//  ImageUpload.swift
//  Mople
//
//  Created by CatSlave on 1/18/25.
//

import Foundation

/// 단일 이미지 업로드 (프로필, 모임 대표 이미지 등)
/// - 호출부에서 UIImage → Data 변환 후 전달 (Domain은 UIKit 미참조)
protocol ImageUpload {
    func execute(_ imageData: Data) async throws -> String
}

final class ImageUploadUseCase: ImageUpload {

    private let imageUploadRepo: ImageUploadRepo

    init(imageUploadRepo: ImageUploadRepo) {
        self.imageUploadRepo = imageUploadRepo
    }

    func execute(_ imageData: Data) async throws -> String {
        return try await imageUploadRepo.uploadImage(data: imageData, path: .profile)
    }
}

// MARK: - Mock
#if DEV
final class MockImageUploadUseCase: ImageUpload {
    func execute(_ imageData: Data) async throws -> String {
        print("✅ [Mock] 이미지 업로드 - dataSize: \(imageData.count) bytes")
        let mockImageUrl = "https://mock-cdn.mople.com/images/profile_\(UUID().uuidString).jpg"
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockImageUrl
    }
}
#endif
