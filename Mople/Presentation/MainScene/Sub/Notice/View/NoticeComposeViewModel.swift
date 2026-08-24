//
//  NoticeComposeViewModel.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import Foundation
import Domain

// 공지 작성/수정 공용 화면.
// mode에 따라 create vs edit 분기, 등록 시점에 다른 UseCase 호출.
@MainActor
final class NoticeComposeViewModel: ObservableObject {

    // MARK: - Mode
    enum Mode {
        case create(meetId: Int)
        case edit(notice: Notice)
    }

    // MARK: - State
    @Published var content: String = ""
    @Published var isSubmitting = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var didSubmit = false

    let mode: Mode
    let maxLength: Int = 500

    var canSubmit: Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= maxLength && !isSubmitting
    }

    // 화면 타이틀 / 등록 버튼 텍스트는 mode 분기
    var navigationTitle: String {
        switch mode {
        case .create: return "공지 작성하기"
        case .edit: return "공지 수정"
        }
    }
    var submitButtonTitle: String {
        switch mode {
        case .create: return "작성 완료"
        case .edit: return "수정 완료"
        }
    }

    // MARK: - Dependencies
    private let createUseCase: CreateNotice
    private let updateUseCase: UpdateNotice
    private weak var coordinator: NoticeFlowCoordination?

    init(mode: Mode,
         createUseCase: CreateNotice,
         updateUseCase: UpdateNotice,
         coordinator: NoticeFlowCoordination?) {
        self.mode = mode
        self.createUseCase = createUseCase
        self.updateUseCase = updateUseCase
        self.coordinator = coordinator

        // edit 모드는 기존 본문을 prefill
        if case .edit(let notice) = mode {
            self.content = notice.content ?? ""
        }
    }

    // MARK: - Submit
    func submit() {
        let text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSubmitting else { return }

        isSubmitting = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.isSubmitting = false }
            do {
                // 수정 시 갱신된 Notice를 상세 화면에 전달하기 위해 결과를 보관
                var updatedNotice: Notice?
                switch self.mode {
                case .create(let meetId):
                    _ = try await self.createUseCase.execute(meetId: meetId, content: text)
                case .edit(let notice):
                    guard let noticeId = notice.noticeId, let meetId = notice.meetId else { return }
                    updatedNotice = try await self.updateUseCase.execute(noticeId: noticeId,
                                                                         meetId: meetId,
                                                                         content: text)
                }
                self.didSubmit = true
                // 리스트 reload 트리거 + (수정 시) 상세 본문 즉시 갱신용 payload 전달
                NotificationCenter.default.post(
                    name: .noticeUpdated,
                    object: nil,
                    userInfo: updatedNotice.map { ["notice": $0] }
                )
                // 작성/수정 완료 후엔 modal 전체 종료가 아니라 한 단계 pop만 (list/detail 복귀)
                self.coordinator?.popCurrentView()
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    // 뒤로가기 — Compose는 항상 push로 들어왔으므로 pop만 (modal 전체 종료가 아님)
    func dismissFlow() {
        coordinator?.popCurrentView()
    }
}

// MARK: - Notification.Name
// 공지 생성/수정/삭제 후 발행. 리스트 화면이 구독하여 reload.
extension Notification.Name {
    static let noticeUpdated = Notification.Name("com.mople.noticeUpdated")
}
