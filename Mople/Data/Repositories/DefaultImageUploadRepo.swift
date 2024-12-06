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
        print(#function, #line, "LifeCycle Test DefaultImageUploadRepo Created" )
        self.networkServbice = networkServbice
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultImageUploadRepo Deinit" )
    }
    
    func uploadImage(image: Data, path: ImageUploadPath) -> Single<Data> {
        let endpoint = APIEndpoints.uploadImage(image, folderPath: path)
        
        return self.networkServbice.basicRequest(endpoint: endpoint)
            
    }
}
