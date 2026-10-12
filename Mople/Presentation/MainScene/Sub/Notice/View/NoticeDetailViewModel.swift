//
//  NoticeDetailViewModel.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import Foundation
import Domain
import Data   // DataRequestError.isHandledError 사용 (취소/이미 처리된 에러 필터)

// 공지 상세 화면의 상태 머신.
// 진입 시점에 Notice 객체를 받아 본문을 즉시 그리고, 댓글만 별도 API로 로드한다.
// (서버에 공지 단건 GET이 없어 List 응답을 그대로 넘겨받는 구조)
@MainActor
final class NoticeDetailViewModel: ObservableObject {

    // MARK: - Comment Write Mode
    // PostDetail의 WriteMode와 동일 패턴. .edit 모드면 입력바 위에 "댓글 수정중" 라벨 표시.
    enum WriteMode: Equatable {
        case basic
        case edit(commentId: Int)
    }

    // MARK: - State
    @Published private(set) var notice: Notice
    @Published var comments: [Comment] = []
    // 댓글 수는 일정/리뷰와 동일하게 서버 totalCount를 사용 (로컬 로드 수가 아님)
    @Published private(set) var totalCount: Int = 0
    @Published var inputText: String = ""
    @Published var writeMode: WriteMode = .basic
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var showError = false
    @Published var errorMessage = ""

    let isCreator: Bool

    var hasComments: Bool { !comments.isEmpty }
    var canSubmit: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }
    var isEditingComment: Bool {
        if case .edit = writeMode { return true } else { return false }
    }

    // MARK: - Dependencies
    private let fetchNoticeUseCase: FetchNotice
    private let fetchCommentsUseCase: FetchNoticeCommentList
    private let createCommentUseCase: CreateNoticeComment
    private let editCommentUseCase: EditNoticeComment
    private let deleteCommentUseCase: DeleteComment
    private let reportUseCase: ReportPost
    private let deleteNoticeUseCase: DeleteNotice
    private weak var coordinator: NoticeFlowCoordination?
    private var pageInfo: PageInfo?
    private var isLoadingMore = false
    // 블록 기반 옵저버 토큰 (deinit에서 해제)
    private var noticeUpdateToken: NSObjectProtocol?

    init(notice: Notice,
         isCreator: Bool,
         fetchNoticeUseCase: FetchNotice,
         fetchCommentsUseCase: FetchNoticeCommentList,
         createCommentUseCase: CreateNoticeComment,
         editCommentUseCase: EditNoticeComment,
         deleteCommentUseCase: DeleteComment,
         reportUseCase: ReportPost,
         deleteNoticeUseCase: DeleteNotice,
         coordinator: NoticeFlowCoordination?) {
        self.notice = notice
        self.isCreator = isCreator
        self.fetchNoticeUseCase = fetchNoticeUseCase
        self.fetchCommentsUseCase = fetchCommentsUseCase
        self.createCommentUseCase = createCommentUseCase
        self.editCommentUseCase = editCommentUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.reportUseCase = reportUseCase
        self.deleteNoticeUseCase = deleteNoticeUseCase
        self.coordinator = coordinator

        // 진입 시 공지 본문을 fresh하게 다시 받는다 (목록에서 건네받은 값은 stale일 수 있음)
        Task { await self.loadNotice() }

        // 시스템 공지는 댓글이 없으니 fetch 스킵
        if notice.type != .system {
            Task { await self.loadComments() }
        }

        // Compose 화면에서 공지 수정 완료 시 본문 갱신을 받기 위해 notification 구독
        observeNoticeUpdate()
    }

    // MARK: - Notification (공지 수정 완료 시 본문 갱신)
    // Compose에서 수정 완료 시 userInfo["notice"]에 갱신된 Notice를 실어 발행한다.
    // 같은 공지면 본문을 즉시 교체해 stale 표시를 막는다 (일정/리뷰의 수정 즉시 반영과 동일).
    private func observeNoticeUpdate() {
        noticeUpdateToken = NotificationCenter.default.addObserver(
            forName: .noticeUpdated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let updated = notification.userInfo?["notice"] as? Notice
            Task { @MainActor [weak self] in
                guard let self,
                      let updated,
                      updated.noticeId == self.notice.noticeId else { return }
                self.notice = updated
            }
        }
    }

    deinit {
        if let token = noticeUpdateToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    // MARK: - Notice (단건 본문 fresh 조회)
    // 진입/새로고침 시 호출. 실패해도 이미 들고 있는 notice로 표시를 유지(조용히 무시).
    func loadNotice() async {
        guard let noticeId = notice.noticeId else { return }
        do {
            let fresh = try await fetchNoticeUseCase.execute(noticeId: noticeId)
            self.notice = fresh
        } catch {
            // 취소/이미 처리된 에러는 무시. 그 외 본문 갱신 실패도 화면을 막지 않도록 조용히 둔다.
            guard !DataRequestError.isHandledError(err: error) else { return }
        }
    }

    // MARK: - Comments
    // showLoadingIndicator: 전체 화면 로딩 오버레이(customNavigationBar isLoading) 표시 여부.
    // 초기 로드는 true, 당겨서 새로고침은 false(.refreshable 자체 스피너가 있어 오버레이가 겹치면 화면이 깨져 보임).
    func loadComments(showLoadingIndicator: Bool = true) async {
        guard let noticeId = notice.noticeId else { return }
        if showLoadingIndicator { isLoading = true }
        defer {
            if showLoadingIndicator { isLoading = false }
        }

        do {
            let page = try await fetchCommentsUseCase.execute(noticeId: noticeId,
                                                              size: nil,
                                                              cursor: nil)
            self.comments = page.content
            self.pageInfo = page.info
            // 서버 totalCount 우선, 미제공(0) 시 로드된 개수로 폴백
            self.totalCount = max(page.totalCount, page.content.count)
        } catch {
            // 이미 처리된(.handled) 에러(요청 취소 등)는 alert를 띄우지 않는다 (기존 Reactor와 동일 패턴).
            guard !DataRequestError.isHandledError(err: error) else { return }
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    // MARK: - Pagination
    // 일정/리뷰 댓글과 동일하게 스크롤 하단 도달 시 다음 페이지를 이어 로드한다.
    func loadMoreIfNeeded(currentItem: Comment) {
        guard let pageInfo, pageInfo.hasNext, !isLoadingMore else { return }
        // 마지막(가장 오래된) 댓글이 화면에 등장하면 다음 페이지 요청
        guard comments.last?.id == currentItem.id else { return }
        Task { await loadMore() }
    }

    private func loadMore() async {
        guard let noticeId = notice.noticeId,
              let cursor = pageInfo?.nextCursor,
              !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let page = try await fetchCommentsUseCase.execute(noticeId: noticeId,
                                                              size: nil,
                                                              cursor: cursor)
            self.comments.append(contentsOf: page.content)
            self.pageInfo = page.info
            if page.totalCount > 0 { self.totalCount = page.totalCount }
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    // 댓글 작성/수정 통합 진입점 — writeMode에 따라 분기
    func submitComment() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSubmitting else { return }

        switch writeMode {
        case .basic:
            createComment(text: text)
        case .edit(let commentId):
            editComment(commentId: commentId, text: text)
        }
    }

    private func createComment(text: String) {
        guard let noticeId = notice.noticeId else { return }
        isSubmitting = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.isSubmitting = false }
            do {
                let created = try await self.createCommentUseCase.execute(noticeId: noticeId,
                                                                          content: text,
                                                                          mentions: [])
                // 댓글은 최신순 — 새 댓글을 상단에 삽입 (일정/리뷰와 동일)
                self.comments.insert(created, at: 0)
                self.totalCount += 1
                self.inputText = ""
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    private func editComment(commentId: Int, text: String) {
        isSubmitting = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.isSubmitting = false }
            do {
                let updated = try await self.editCommentUseCase.execute(noticeId: commentId,
                                                                        content: text,
                                                                        mentions: [])
                if let idx = self.comments.firstIndex(where: { $0.id == updated.id }) {
                    self.comments[idx] = updated
                }
                self.cancelCommentEdit()
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    func cancelCommentEdit() {
        writeMode = .basic
        inputText = ""
    }

    // MARK: - Comment Menu (시트 액션에서 호출)
    func startEditComment(_ comment: Comment) {
        guard let commentId = comment.id else { return }
        writeMode = .edit(commentId: commentId)
        inputText = comment.comment ?? ""
    }

    func deleteComment(_ comment: Comment) {
        guard let commentId = comment.id else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.deleteCommentUseCase.execute(commentId: commentId)
                self.comments.removeAll { $0.id == commentId }
                self.totalCount = max(0, self.totalCount - 1)
                // 편집 중이던 댓글을 지운 경우 입력바 초기화
                if case .edit(let editId) = self.writeMode, editId == commentId {
                    self.cancelCommentEdit()
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    func reportComment(_ comment: Comment) {
        guard let commentId = comment.id else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.reportUseCase.execute(type: .comment(id: commentId), reason: nil)
                ToastManager.shared.presentToast(text: L10n.Report.completed)
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    // 댓글 셀의 menu 버튼 → 시트 표시
    func showCommentMenu(for comment: Comment) {
        // 시트 액션 enum 분기를 View가 들고있지 않게 ViewModel에서 조립.
        if comment.isWriter {
            let editAction = DefaultSheetAction(text: L10n.Comment.edit, image: .editComment) { [weak self] in
                self?.startEditComment(comment)
            }
            let deleteAction = DefaultSheetAction(text: L10n.Comment.delete, image: .delete) { [weak self] in
                self?.deleteComment(comment)
            }
            SheetManager.shared.showSheet(actions: [editAction, deleteAction])
        } else {
            let reportAction = DefaultSheetAction(text: L10n.Report.comment, image: .report) { [weak self] in
                self?.reportComment(comment)
            }
            SheetManager.shared.showSheet(actions: [reportAction])
        }
    }

    // MARK: - Page Menu (우상단 점 세 개)
    // 모임장: "공지 수정" + "공지 삭제"
    // 모임원: "신고하기" (공지 신고 API 미구현 — placeholder Toast)
    func showPageMenu() {
        if isCreator {
            let editAction = DefaultSheetAction(text: L10n.Notice.edit, image: .editPlan) { [weak self] in
                guard let self else { return }
                self.coordinator?.pushEditView(notice: self.notice)
            }
            let deleteAction = DefaultSheetAction(text: L10n.Notice.delete, image: .delete) { [weak self] in
                self?.deleteNotice()
            }
            SheetManager.shared.showSheet(actions: [editAction, deleteAction])
        } else {
            let reportAction = DefaultSheetAction(text: L10n.Notice.report, image: .report) { [weak self] in
                self?.reportNoticePlaceholder()
            }
            SheetManager.shared.showSheet(actions: [reportAction])
        }
    }

    private func deleteNotice() {
        guard let noticeId = notice.noticeId else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.deleteNoticeUseCase.execute(noticeId: noticeId)
                NotificationCenter.default.post(name: .noticeUpdated, object: nil)
                self.coordinator?.popCurrentView()
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    // TODO: 백엔드에 /notice/report 추가되면 ReportType.notice(id:) 분기로 교체
    private func reportNoticePlaceholder() {
        ToastManager.shared.presentToast(text: L10n.Report.completed)
    }

    // MARK: - Profile Tap
    func tapProfile(name: String?, imagePath: String?) {
        coordinator?.presentProfileImage(name: name, imagePath: imagePath)
    }

    // MARK: - Navigation
    func dismissFlow() {
        coordinator?.endFlow()
    }
}
