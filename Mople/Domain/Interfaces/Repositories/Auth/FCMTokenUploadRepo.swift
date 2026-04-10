//
//  FCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

protocol FCMTokenUploadRepo {
    func uploadFCMToken(_ token: String) async throws
}
