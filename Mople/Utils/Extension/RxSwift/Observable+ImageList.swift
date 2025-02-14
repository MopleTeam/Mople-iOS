//
//  Observable+ImageList.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import UIKit
import RxSwift

extension Observable where Element == UIImage? {
    static func imagesTaskBuilder(imageUrls: [URL]) -> [Observable<Element>] {
        return imageUrls.map { url in
            Observable<UIImage?>.create { emitter in
                let task = url.fetchImage { image in
                    emitter.onNext(image)
                    emitter.onCompleted()
                }

                return Disposables.create {
                    task?.cancel()
                }
            }
        }
    }
}

extension Observable where Element == ImageWrapper {
    static func reviewImagesTaskBuilder(_ reviewImages: [ReviewImage]) -> [Observable<Element>] {
        return reviewImages.map { reviewImage in
            Observable<ImageWrapper>.create { emitter in
                guard let imagePath = reviewImage.reviewImage,
                      let id = reviewImage.imageId,
                      let url = URL(string: imagePath) else { return Disposables.create() }
                
                let task = url.fetchImage { image in
                    guard let image else {
                        emitter.onCompleted()
                        return
                    }
                    emitter.onNext(.init(image: image,
                                         isNew: false,
                                         id: "\(id)"))
                    emitter.onCompleted()
                }

                return Disposables.create {
                    task?.cancel()
                }
            }
        }
    }
}
