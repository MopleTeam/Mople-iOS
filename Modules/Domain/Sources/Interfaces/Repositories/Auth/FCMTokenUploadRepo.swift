//
//  FCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

public protocol FCMTokenUploadRepo {
    func uploadFCMToken(_ token: String) async throws
}
