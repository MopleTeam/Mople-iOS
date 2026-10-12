//
//  DefaultFCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation
import Domain

public final class DefaultFCMTokenRepo: BaseRepositories, FCMTokenUploadRepo {

    public func uploadFCMToken(_ token: String) async throws {
        try await networkService.authenticatedRequest {
            try APIEndpoints.uploadFCMToken(token)
        }
        UserDefaults.saveFCMToken(token)
    }
}

