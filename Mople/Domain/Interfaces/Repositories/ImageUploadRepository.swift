//
//  ImageUploadRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

protocol ImageUploadRepository {
    func uploadImage(image: Data?) -> Single<String?>
}
