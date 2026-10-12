//
//  DefaultNotifyRepo.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//
import Foundation
import Domain

/// 앱 뱃지 초기화를 위한 프로토콜 (UIKit 의존 제거)
public protocol AppBadgeResettable {
    @MainActor func resetBadge()
}

public final class DefaultNotifyRepo: BaseRepositories, NotifyRepo {

    private let badgeResetter: AppBadgeResettable?

    public init(networkService: AppNetworkService, badgeResetter: AppBadgeResettable? = nil) {
        self.badgeResetter = badgeResetter
        super.init(networkService: networkService)
    }

    public func fetchNotifyList(cursor: String?) async throws -> Page<Notify> {
        let response: PageResponse<NotifyResponse> = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchNotify(cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    @MainActor
    public func resetNotifyCount() async throws {
        try await networkService.authenticatedRequest {
            try APIEndpoints.resetNotifyCount()
        }
        UserInfoStorage.shared.updateNotifyStatus(hasNotify: false)
        badgeResetter?.resetBadge()
    }
}
