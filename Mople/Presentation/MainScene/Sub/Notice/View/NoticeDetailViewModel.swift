//
//  NoticeDetailViewModel.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import Foundation
import Domain

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
    private let fetchCommentsUseCase: FetchNoticeCommentList
    private let createCommentUseCase: CreateNoticeComment
    private let editCommentUseCase: EditComment
    private let deleteCommentUseCase: DeleteComment
    private let reportUseCase: ReportPost
    private let deleteNoticeUseCase: DeleteNotice
    private weak var coordinator: NoticeFlowCoordination?
    private var pageInfo: PageInfo?

    init(notice: Notice,
         isCreator: Bool,
         fetchCommentsUseCase: FetchNoticeCommentList,
         createCommentUseCase: CreateNoticeComment,
         editCommentUseCase: EditComment,
         deleteCommentUseCase: DeleteComment,
         reportUseCase: ReportPost,
         deleteNoticeUseCase: DeleteNotice,
         coordinator: NoticeFlowCoordination?) {
        self.notice = notice
        self.isCreator = isCreator
        self.fetchCommentsUseCase = fetchCommentsUseCase
        self.createCommentUseCase = createCommentUseCase
        self.editCommentUseCase = editCommentUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.reportUseCase = reportUseCase
        self.deleteNoticeUseCase = deleteNoticeUseCase
        self.coordinator = coordinator

        // 시스템 공지는 댓글이 없으니 fetch 스킵
        if notice.type != .system {
            Task { await self.loadComments() }
        }

        // Compose 화면에서 공지 수정 완료 시 본문 갱신을 받기 위해 notification 구독
        observeNoticeUpdate()
    }

    // MARK: - Notification (공지 수정 완료 시 본문 갱신)
    private func observeNoticeUpdate() {
        NotificationCenter.default.addObserver(forName: .noticeUpdated,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            // 현재 본문을 그대로 두면 stale. 일단 dismiss하지 않고 placeholder 유지.
            // 보다 정확한 갱신은 list로 돌아간 후 fetch에 맡김.
            _ = self
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Comments
    func loadComments() async {
        guard let noticeId = notice.noticeId else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await fetchCommentsUseCase.execute(noticeId: noticeId,
                                                              size: nil,
                                                              cursor: nil)
            self.comments = page.content
            self.pageInfo = page.info
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
                self.comments.append(created)
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
                let updated = try await self.editCommentUseCase.execute(id: commentId,
                                                                        text: text,
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
            let reportAction = DefaultSheetAction(text: "신고하기", image: .report) { [weak self] in
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
            let editAction = DefaultSheetAction(text: "공지 수정", image: .editPlan) { [weak self] in
                guard let self else { return }
                self.coordinator?.pushEditView(notice: self.notice)
            }
            let deleteAction = DefaultSheetAction(text: "공지 삭제", image: .delete) { [weak self] in
                self?.deleteNotice()
            }
            SheetManager.shared.showSheet(actions: [editAction, deleteAction])
        } else {
            let reportAction = DefaultSheetAction(text: "신고하기", image: .report) { [weak self] in
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
