//
//  FCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation

protocol FcmTokenUploadRepo {
    func uploadFCMToken(_ token: String)
}
