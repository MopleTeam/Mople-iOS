//
//  DefaultNoticeRepo.swift
//  Data
//
//  Created by CatSlave on 5/26/26.
//

import Foundation
import Domain

public final class DefaultNoticeRepo: BaseRepositories, NoticeRepo {

    // MARK: - 공지 CRUD
    public func fetchNoticeList(meetId: Int,
                                type: NoticeType?,
                                size: Int?,
                                cursor: String?) async throws -> Page<Notice> {
        let response: PageResponse<NoticeResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchNoticeList(meetId: meetId,
                                             type: type?.rawValue,
                                             size: size,
                                             cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    public func fetchNoticeDetail(noticeId: Int) async throws -> Notice {
        let response: NoticeResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchNoticeDetail(noticeId: noticeId)
        }
        return response.toDomain()
    }

    public func createNotice(meetId: Int,
                             content: String) async throws -> Notice {
        let response: NoticeResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.createNotice(meetId: meetId,
                                          content: content)
        }
        return response.toDomain()
    }

    public func updateNotice(noticeId: Int,
                             meetId: Int,
                             content: String) async throws -> Notice {
        let response: NoticeResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.updateNotice(noticeId: noticeId,
                                          meetId: meetId,
                                          content: content)
        }
        return response.toDomain()
    }

    public func deleteNotice(noticeId: Int) async throws {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.deleteNotice(noticeId: noticeId)
        }
    }

    // MARK: - 고정 토글
    public func pinNotice(noticeId: Int) async throws -> Notice {
        let response: NoticeResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.pinNotice(noticeId: noticeId)
        }
        return response.toDomain()
    }

    public func unpinNotice(noticeId: Int) async throws -> Notice {
        let response: NoticeResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.unpinNotice(noticeId: noticeId)
        }
        return response.toDomain()
    }

    // MARK: - 공지 댓글
    public func fetchNoticeCommentList(noticeId: Int,
                                       size: Int?,
                                       cursor: String?) async throws -> Page<Comment> {
        let response: PageResponse<NoticeCommentResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchNoticeCommentList(noticeId: noticeId,
                                                    size: size,
                                                    cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    public func createNoticeComment(noticeId: Int,
                                    content: String,
                                    mentions: [Int]) async throws -> Comment {
        let response: NoticeCommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.createNoticeComment(noticeId: noticeId,
                                                 content: content,
                                                 mentions: mentions)
        }
        return response.toDomain()
    }
    
    public func editNoticeComment(noticeId: Int,
                                  content: String,
                                  mentions: [Int]) async throws -> Comment {
        let response: NoticeCommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.editNoticeComment(noticeId: noticeId,
                                               content: content,
                                               mentions: mentions)
        }
        return response.toDomain()
    }
}
