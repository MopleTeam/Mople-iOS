//
//  ImageUploadMock.swift
//  Mople
//
//  Created by CatSlave on 1/18/25.
//

import UIKit
import RxSwift

final class ImageUploadMock: ImageUpload {
    func execute(_ image: UIImage?) -> Single<String?> {
        return Observable.just("테스트")
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
