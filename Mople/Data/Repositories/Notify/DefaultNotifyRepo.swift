//
//  DefaultNotifyRepo.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//
import UIKit
import Domain

final class DefaultNotifyRepo: BaseRepositories, NotifyRepo {
    func fetchNotifyList(cursor: String?) async throws -> Page<Notify> {
        let response: PageResponse<NotifyResponse> = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchNotify(cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
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
