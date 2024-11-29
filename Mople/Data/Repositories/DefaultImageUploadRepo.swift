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

final class DefaultImageUploadRepo: ImageUploadRepo {
    private let networkServbice: AppNetWorkService
    
    init(networkServbice: AppNetWorkService) {
        self.networkServbice = networkServbice
    }
    
    func uploadImage(image: Data, path: ImageUploadPath) -> Single<Data> {
        let endpoint = APIEndpoints.uploadImage(image, folderPath: path)
        
        return self.networkServbice.basicRequest(endpoint: endpoint)
            
    }
}
