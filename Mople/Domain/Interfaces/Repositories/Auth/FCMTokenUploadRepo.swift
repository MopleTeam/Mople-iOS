//
//  FCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import RxSwift

protocol FCMTokenUploadRepo {
    func uploadFCMToken(_ token: String) 
}
