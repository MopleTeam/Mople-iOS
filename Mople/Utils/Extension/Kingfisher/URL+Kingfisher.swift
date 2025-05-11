//
//  UIImage+Kingfisher.swift
//  Mople
//
//  Created by CatSlave on 2/12/25.
//

import UIKit
import Kingfisher

extension URL {
    func fetchImage(completion: @escaping (UIImage?) -> Void) -> DownloadTask? {
        KingfisherManager.shared.retrieveImage(with: self) { result in
            switch result {
            case let .success(value):
                completion(value.image)
            default:
                completion(nil)
            }
        }
    }
}


