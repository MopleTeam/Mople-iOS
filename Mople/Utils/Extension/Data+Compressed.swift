//
//  Data+Compressed.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

enum CompressionPhotoError: Error {
    case maxQualityReached
    case compressionFailed
    
    var info: String {
        return "사진을 업로드할 수 없어요."
    }
    var subInfo: String {
        return "선택된 사진의 용량이 너무 커요."
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
