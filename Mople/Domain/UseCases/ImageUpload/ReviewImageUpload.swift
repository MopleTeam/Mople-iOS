//
//  ReviewImageUpload.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import UIKit

protocol ReviewImageUpload {
    func execute(id: Int,
                 images: [UIImage]) async throws
}

enum CompressionPhotosError: Error {
    case compressionFailed(indexs: [Int])

    var info: String {
        return L10n.Error.Photo.upload
    }
    var subInfo: String {
        switch self {
        case let .compressionFailed(index):
            let str = index.map { "\($0)" }.joined(separator: ", ")
            return L10n.Error.Photo.mutipleCompression(str)
        }
    }
}

final class ReviewImageUploadUseCase: ReviewImageUpload {

    private let repo: ImageUploadRepo

    init(repo: ImageUploadRepo) {
        self.repo = repo
    }

    func execute(id: Int,
                 images: [UIImage]) async throws {

        var compressImageDatas: [Data] = .init()
        var failIndexs: [Int] = .init()
        handleCompressImage(images: images,
                            datas: &compressImageDatas,
                            failIndexs: &failIndexs)

        if failIndexs.isEmpty {
            try await repo
                .uploadReviewImages(id: id,
                                    images: compressImageDatas)
        } else {
            throw CompressionPhotosError.compressionFailed(indexs: failIndexs)
        }
    }

    private func handleCompressImage(images: [UIImage],
                                     datas: inout [Data],
                                     failIndexs: inout [Int]) {
        images.enumerated().forEach { (index, image) in
            do {
                let data = try Data.imageDataCompressed(uiImage: image)
                datas.append(data)
            } catch {
                failIndexs.append(index + 1)
            }
        }
    }
}

// MARK: - Mock
#if DEV
final class MockReviewImageUploadUseCase: ReviewImageUpload {
    func execute(id: Int, images: [UIImage]) async throws {
        print("✅ [Mock] 후기 이미지 업로드 - reviewId: \(id), imageCount: \(images.count)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
#endif
