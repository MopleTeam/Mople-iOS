//
//  ImageWrapper.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import UIKit
import Domain

struct ImageWrapper {
    let path: String?
    let id: Int?
    let image: UIImage?
    
    var isNew: Bool { path == nil }
    
    init(path: String? = nil,
         id: Int? = nil,
         image: UIImage? = nil) {
        self.path = path
        self.id = id
        self.image = image
    }
}

extension ImageWrapper {
    func toImageInfo() -> ImageInfo {
        return .init(path: path,
                     image: image)
    }
}
