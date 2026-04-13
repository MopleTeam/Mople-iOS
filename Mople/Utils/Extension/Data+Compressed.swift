//
//  Data+Compressed.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import Domain

// MARK: - 단일 이미지 압축 에러
enum CompressionPhotoError: Error {
    case maxQualityReached
    case compressionFailed

    var info: String {
        return L10n.Error.Photo.upload
    }
    var subInfo: String {
        return L10n.Error.Photo.singleCompression
    }
}

// MARK: - 복수 이미지 압축 에러 (리뷰 이미지 등)
/// Domain에서 이동 — L10n 참조로 인해 Presentation/Utils 레이어에 위치
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

extension Data {
    
    static func imageDataCompressed(uiImage: UIImage,
                                    quality: CGFloat = 0.5) throws -> Self {
        let maxSize = 1_000_000

        guard quality >= 0 else { throw CompressionPhotoError.maxQualityReached }
        guard let data = uiImage.jpegData(compressionQuality: quality) else { throw CompressionPhotoError.compressionFailed }
        guard data.count >= maxSize else { return data }
        
        return try imageDataCompressed(uiImage: uiImage,
                                       quality: quality - 0.1)
    }
}
