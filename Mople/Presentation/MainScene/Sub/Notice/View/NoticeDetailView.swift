//
//  NoticeDetailView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import SwiftUI
import Domain

// 공지 상세. type에 따라 두 모드:
// - .custom (모임공지): 본문 카드 + 댓글 섹션 + 하단 입력바
// - .system (시스템): 본문만 — 작성자 = "Mople" + 앱 로고, 댓글/입력바 없음
// 좋아요 기능은 백엔드 API 미구현이라 UI에서 제외.
// 우상단 점 세개 메뉴: 모임장이면 "공지 수정/삭제", 모임원이면 "신고하기".
struct NoticeDetailView: View {

    @StateObject private var viewModel: NoticeDetailViewModel
    @FocusState private var inputFocused: Bool

    init(viewModel: NoticeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var isSystem: Bool { viewModel.notice.type == .system }
    private var navigationTitle: String { isSystem ? "시스템" : "상세보기" }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    noticeBody
                    if !isSystem {
                        Color(uiColor: .bgSecondary)
                            .frame(height: 8)
                        commentSection
                    }
                }
            }
            if !isSystem {
                inputBar
            }
        }
        .background(Color(uiColor: .bgPrimary))
        // 키보드 dismiss는 InteractivePopHostingController의 UIKit tap recognizer가 담당
        .customNavigationBar(title: navigationTitle,
                             isLoading: viewModel.isLoading,
                             trailing: { trailingMenuButton })
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - 우상단 메뉴 버튼 (시스템 공지에는 메뉴 노출 X)
    @ViewBuilder
    private var trailingMenuButton: some View {
        if !isSystem {
            Button(action: { viewModel.showPageMenu() }) {
                Image(.blackMenu)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .frame(width: 40, height: 40)
        }
    }

    // MARK: - 본문 (Header + Content)
    private var noticeBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            authorHeader
            Text(viewModel.notice.content ?? "")
                .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text01))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .bgPrimary))
    }

    private var authorHeader: some View {
        HStack(spacing: 8) {
            authorAvatar
            VStack(alignment: .leading, spacing: 2) {
                Text(authorName)
                    .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.body1))
                    .foregroundColor(Color(uiColor: .text01))
                HStack(spacing: 4) {
                    if let date = viewModel.notice.createdAt {
                        Text(NoticeDateFormatter.absolute(from: date))
                        Text("·")
                            .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body2))
                        Text(NoticeDateFormatter.relative(from: date))
                    }
                }
                .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body2))
                .foregroundColor(Color(uiColor: .text03))
            }
            Spacer(minLength: 0)
        }
    }

    // 시스템 공지는 Mople 앱 로고. 일반 공지는 도메인에 작성자 정보가 없어
    // 일단 기본 프로필(.defaultUser)을 사용 (백엔드에서 writer 응답 추가되면 교체).
    @ViewBuilder
    private var authorAvatar: some View {
        if isSystem {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(.defaultUser)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        }
    }

    private var authorName: String {
        isSystem ? "Mople" : "모임공지"
    }

    // MARK: - 댓글 섹션 (custom 전용)
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("댓글")
                    .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                    .foregroundColor(Color(uiColor: .text01))
                Spacer()
                Text("\(viewModel.comments.count)개")
                    .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                    .foregroundColor(Color(uiColor: .text03))
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 8)

            ForEach(viewModel.comments, id: \.id) { comment in
                NoticeCommentRow(
                    comment: comment,
                    onProfileTap: {
                        viewModel.tapProfile(name: comment.writerName,
                                             imagePath: comment.writerThumbnailPath)
                    },
                    onMenuTap: {
                        viewModel.showCommentMenu(for: comment)
                    }
                )
            }
        }
        .background(Color(uiColor: .bgPrimary))
    }

    // MARK: - 입력바 (ChatingTextFieldView 레이아웃 SwiftUI 재구현, 멘션 제외)
    // 박스형 입력(.bgInput, cornerRadius 8) + 우측 52pt 폭의 send 영역 + (edit 모드 시) 상단 라벨.
    // ChatingTextFieldView와 동일하게 키보드 떠있을 때(inputFocused == true)만 send 버튼 노출.
    private var inputBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isEditingComment {
                editLabelRow
            }

            HStack(alignment: .bottom, spacing: 0) {
                inputBox
                if inputFocused {
                    sendButton
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        // 하단은 ChatingTextFieldView와 동일하게 safeArea만 — 추가 padding 없음
        .background(Color(uiColor: .bgPrimary))
    }

    // "댓글 수정중" 뱃지 + 취소 (UIKit editLabel: 25x70, cornerRadius 4, bgSecondary, Body2.medium, text03)
    private var editLabelRow: some View {
        HStack(spacing: 8) {
            Text("댓글 수정중")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body2))
                .foregroundColor(Color(uiColor: .text03))
                .frame(width: 70, height: 25)
                .background(Color(uiColor: .bgSecondary))
                .cornerRadius(4)
            Button("취소") {
                viewModel.cancelCommentEdit()
                inputFocused = false
            }
            .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body2))
            .foregroundColor(Color(uiColor: .text02))
            Spacer(minLength: 0)
        }
    }

    // DefaultTextView 박스: bgInput + cornerRadius 8 + 내부 padding (좌우 8, 상하 18)
    // TextEditor는 UIKit UITextView 기반이라 ChatingTextFieldView와 동일하게
    // 줄바꿈/자동 높이 확장/초과 시 자체 스크롤 동작이 매칭됨.
    // 높이는 minHeight(1줄) ~ maxHeight(4줄) 범위에서 콘텐츠에 맞춰 자동.
    private var inputBox: some View {
        // Body1.regular(=14pt) lineHeight ≈ 14 * 1.4 = 19.6pt 가정.
        // ChatingTextFieldView의 maxTextLine 4 매핑 → 4줄까지 늘어나고 그 이상은 내부 스크롤.
        let lineHeight: CGFloat = 20
        let minHeight: CGFloat = lineHeight
        let maxHeight: CGFloat = lineHeight * 4

        return ZStack(alignment: .topLeading) {
            if viewModel.inputText.isEmpty {
                Text("댓글을 입력해주세요")
                    .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body1))
                    .foregroundColor(Color(uiColor: .text04))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 18)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $viewModel.inputText)
                .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text01))
                .tint(Color(uiColor: .text02))
                .focused($inputFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .fixedSize(horizontal: false, vertical: true)
                // TextEditor 내부 inset(약 ~5pt)을 빼고 ChatingTextFieldView padding(8/18)에 맞춤
                .padding(.horizontal, 3)
                .padding(.vertical, 13)
        }
        .background(Color(uiColor: .bgInput))
        .cornerRadius(8)
    }

    // sendButton: ChatingTextFieldView 정확 매핑
    //   - 전체 폭 52
    //   - 아이콘 영역: leading 12, trailing 0, bottom 6, height = width (1:1 정사각형 = 40x40)
    private var sendButton: some View {
        Button(action: {
            inputFocused = false
            viewModel.submitComment()
        }) {
            Color.clear
                .overlay(alignment: .bottom) {
                    Image(viewModel.canSubmit ? .sendArrowCircle : .sendArrowCircleDisable)
                        .resizable()
                        .scaledToFit()
                        .padding(.leading, 12)
                        .padding(.bottom, 6)
                }
        }
        .frame(width: 52)
        .disabled(!viewModel.canSubmit)
    }
}

// MARK: - Comment Row
// 피그마 3849-4280: 32 avatar + (이름 SemiBold 14 + 시간 Regular 12 + more) + 본문 Medium 14
// 셀 하단 hairline (.appStroke). 프로필 탭 → 큰 이미지 view, more 탭 → 메뉴 시트.
private struct NoticeCommentRow: View {
    let comment: Comment
    let onProfileTap: () -> Void
    let onMenuTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            avatar
                .onTapGesture { onProfileTap() }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(comment.writerName ?? "익명")
                        .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.body1))
                        .foregroundColor(Color(uiColor: .text01))
                    Text(relativeTime)
                        .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body2))
                        .foregroundColor(Color(uiColor: .text03))
                    Spacer(minLength: 0)
                    Button(action: onMenuTap) {
                        Image(.menu)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(uiColor: .text03))
                    }
                }
                Text(comment.comment ?? "")
                    .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                    .foregroundColor(Color(uiColor: .text02))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(uiColor: .appStroke))
                .frame(height: 1)
        }
    }

    private var avatar: some View {
        Group {
            if let path = comment.writerThumbnailPath, let url = URL(string: path) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(.defaultUser).resizable()
                }
            } else {
                Image(.defaultUser).resizable()
            }
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
    }

    private var relativeTime: String {
        guard let date = comment.createdDate else { return "" }
        return NoticeDateFormatter.relative(from: date)
    }
}
