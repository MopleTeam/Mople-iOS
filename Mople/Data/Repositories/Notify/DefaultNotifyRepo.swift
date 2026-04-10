//
//  DefaultNotifyRepo.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//
import UIKit

final class DefaultNotifyRepo: BaseRepositories, NotifyRepo {
    func fetchNotifyList(cursor: String?) async throws -> PageResponse<NotifyResponse> {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchNotify(cursor: cursor)
        }
    }

    @MainActor
    func resetNotifyCount() async throws {
        try await networkService.authenticatedRequest {
            try APIEndpoints.resetNotifyCount()
        }
        UserInfoStorage.shared.updateNotifyStatus(hasNotify: false)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
