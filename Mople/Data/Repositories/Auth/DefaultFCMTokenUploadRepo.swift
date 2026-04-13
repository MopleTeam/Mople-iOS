//
//  DefaultFCMTokenUploadRepo.swift
//  Mople
//
//  Created by CatSlave on 11/29/24.
//

import Foundation
import Domain

final class DefaultFCMTokenRepo: BaseRepositories, FCMTokenUploadRepo {

    func uploadFCMToken(_ token: String) async throws {
        try await networkService.authenticatedRequest {
            try APIEndpoints.uploadFCMToken(token)
        }
        UserDefaults.saveFCMToken(token)
    }
}

