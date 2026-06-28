//
//  NoticeRepo.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//
//  모임 공지(Notice) + 공지 댓글 API 추상화.
//  - 공지 CRUD/고정 토글: /notice/*
//  - 공지 댓글 조회/생성: /comment/notice/{noticeId}
//  - 공지 댓글 수정/삭제: 일반 CommentRepo.editComment / deleteComment 재사용 (URL 공통)
//

import Foundation

public protocol NoticeRepo {

    // MARK: - 공지 CRUD
    func fetchNoticeList(meetId: Int,
                         size: Int?,
                         cursor: String?) async throws -> Page<Notice>

    // 단건 상세 조회 — 상세 화면 진입/새로고침 시 fresh한 공지를 받기 위함
    func fetchNoticeDetail(noticeId: Int) async throws -> Notice

    func createNotice(meetId: Int, content: String) async throws -> Notice

    func updateNotice(noticeId: Int,
                      meetId: Int,
                      content: String) async throws -> Notice

    func deleteNotice(noticeId: Int) async throws

    // MARK: - 고정 토글
    func pinNotice(noticeId: Int) async throws -> Notice
    func unpinNotice(noticeId: Int) async throws -> Notice

    // MARK: - 공지 댓글
    // 게시글 댓글과 별도 endpoint이지만 응답 구조는 동일(Comment)이라 같은 entity로 매핑.
    // 댓글 수정/삭제는 CommentRepo의 editComment / deleteComment 재사용.
    func fetchNoticeCommentList(noticeId: Int,
                                size: Int?,
                                cursor: String?) async throws -> Page<Comment>

    func createNoticeComment(noticeId: Int,
                             content: String,
                             mentions: [Int]) async throws -> Comment
}
