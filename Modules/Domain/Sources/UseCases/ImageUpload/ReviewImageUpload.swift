//
//  ReviewImageUpload.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import Foundation

/// 리뷰 이미지 업로드
/// - 호출부에서 UIImage → Data 변환(압축) 후 전달 (Domain은 UIKit 미참조)
public protocol ReviewImageUpload {
    func execute(id: Int,
                 imagesData: [Data]) async throws
}

public final class ReviewImageUploadUseCase: ReviewImageUpload {

    private let repo: ImageUploadRepo

    public init(repo: ImageUploadRepo) {
        self.repo = repo
    }

    public func execute(id: Int,
                 imagesData: [Data]) async throws {
        try await repo.uploadReviewImages(id: id, images: imagesData)
    }
}

// MARK: - Mock
#if DEV
public final class MockReviewImageUploadUseCase: ReviewImageUpload {
    public init() {}
    public func execute(id: Int, imagesData: [Data]) async throws {
        print("✅ [Mock] 후기 이미지 업로드 - reviewId: \(id), imageCount: \(imagesData.count)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif
