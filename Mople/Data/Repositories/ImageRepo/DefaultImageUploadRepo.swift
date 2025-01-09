//
//  DefaultImageUploadRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import Foundation
import RxSwift

enum ImageUploadPath: String {
    case profile = "profile"
    case meet = "meet"
    case review = "review"
}

final class DefaultImageUploadRepo: BaseRepositories, ImageUploadRepo {
    func uploadImage(image: Data, path: ImageUploadPath) -> Single<Data> {
        let endpoint = APIEndpoints.uploadImage(image, folderPath: path)
        
        return self.networkService.basicRequest(endpoint: endpoint)
            
    }
}
