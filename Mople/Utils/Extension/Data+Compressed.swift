//
//  Data+Compressed.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

extension Data {
    
    enum CompressionError: Error {
        case maxQualityReached
        case compressionFailed
    }
    
    static func imageDataCompressed(uiImage: UIImage?, quality: CGFloat = 0.5) throws -> Self? {
        let maxSize = 1_000_000
        
        guard let uiImage else { return nil }
        guard quality >= 0 else { throw CompressionError.maxQualityReached }
        guard let data = uiImage.jpegData(compressionQuality: quality) else { throw CompressionError.compressionFailed }
        guard data.count >= maxSize else { return data }
        
        return try imageDataCompressed(uiImage: uiImage,
                                       quality: quality - 0.1)
    }
}
