//
//  ReviewImageUpload.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import UIKit
import RxSwift

protocol ReviewImageUpload {
    func execute(id: Int,
                 images: [UIImage]) -> Observable<Void>
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
                 images: [UIImage]) -> Observable<Void> {
        
        return Observable.deferred { [weak self] in
            guard let self else { return .empty() }
            
            var compressImageDatas: [Data] = .init()
            var failIndexs: [Int] = .init()
            handleCompressImage(images: images,
                                datas: &compressImageDatas,
                                failIndexs: &failIndexs)
            
            if failIndexs.isEmpty {
                return repo
                    .uploadReviewImages(id: id,
                                        images: compressImageDatas)
                    .asObservable()
            } else {
                return .error(CompressionPhotosError.compressionFailed(indexs: failIndexs))
            }
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
