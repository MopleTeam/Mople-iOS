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
                 images: [UIImage]) -> Single<Void>
}

enum CompressionPhotosError: Error {
    case compressionFailed(indexs: [Int])
    
    var info: String {
        return "사진을 업로드할 수 없어요."
    }
    var subInfo: String {
        switch self {
        case let .compressionFailed(index):
            let str = index.map { "\($0)" }.joined(separator: ", ")
            return "추가된 사진 중 \(str)번째 사진의 용량이 너무 커요."
        }
    }
}

final class ReviewImageUploadUseCase: ReviewImageUpload {
    
    private let repo: ImageUploadRepo
    
    init(repo: ImageUploadRepo) {
        self.repo = repo
    }
    
    func execute(id: Int,
                 images: [UIImage]) -> Single<Void> {
        
        return Single.deferred { [weak self] in
            guard let self else { return .just(()) }
            
            var compressImageDatas: [Data] = .init()
            var failIndexs: [Int] = .init()
            handleCompressImage(images: images,
                                datas: &compressImageDatas,
                                failIndexs: &failIndexs)
            
            if failIndexs.isEmpty {
                return repo.uploadReviewImages(id: id,
                                               images: compressImageDatas)
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
