//
//  NoticeDetailView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import SwiftUI
import Domain
import Kingfisher

// 공지 상세. type에 따라 두 모드:
// - .custom (모임공지): 본문 카드 + 댓글 섹션 + 하단 입력바
// - .system (시스템): 본문만 — 작성자 = "Mople" + 앱 로고, 댓글/입력바 없음
// 좋아요 기능은 백엔드 API 미구현이라 UI에서 제외.
// 우상단 점 세개 메뉴: 모임장이면 "공지 수정/삭제", 모임원이면 "신고하기".
struct NoticeDetailView: View {

    @StateObject private var viewModel: NoticeDetailViewModel
    @FocusState private var inputFocused: Bool
    // 현재 키보드 높이 — 입력바를 직접 올리기 위해 추적
    @State private var keyboardHeight: CGFloat = 0
    // iOS 18: 스크롤 위치를 offset 단위로 직접 제어 (규칙2 보정/원복용)
    @State private var scrollPosition = ScrollPosition()
    // iOS 18 onScrollGeometryChange로 신뢰성 있게 측정한 값들
    @State private var contentHeight: CGFloat = 0      // 콘텐츠 전체 높이
    @State private var fullContainerHeight: CGFloat = 0 // 키보드 내려가 있을 때의 뷰포트 높이
    @State private var currentOffsetY: CGFloat = 0      // 현재 스크롤 위치
    @State private var savedOffsetY: CGFloat?           // 규칙2로 올리기 전 위치 (내릴 때 원복)

    // 입력바를 키보드 위 10pt 띄우기 위한 하단 inset (홈 인디케이터 safe area 보정)
    // 일정/리뷰의 threshold(10pt) 간격과 동일.
    private var keyboardBottomInset: CGFloat {
        guard keyboardHeight > 0 else { return 0 }
        return max(0, keyboardHeight - UIScreen.getNotchSize() + 10)
    }

    init(viewModel: NoticeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var isSystem: Bool { viewModel.notice.type == .system }
    private var navigationTitle: String { isSystem ? "시스템" : "상세보기" }

    var body: some View {
        // 입력바를 스크롤뷰 '바깥' 형제로 두는 게 핵심 —
        // safeAreaInset/스크롤 내부에 두면 포커스 시 SwiftUI가 자동 스크롤해 위 뷰가 사라진다.
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
            .scrollPosition($scrollPosition)
            // iOS 18: 콘텐츠/뷰포트/현재 오프셋을 정확히 측정 (규칙1·2 판단/보정용)
            .onScrollGeometryChange(for: ScrollMetrics.self) { geo in
                ScrollMetrics(content: geo.contentSize.height,
                              container: geo.containerSize.height,
                              offsetY: geo.contentOffset.y)
            } action: { _, m in
                contentHeight = m.content
                currentOffsetY = m.offsetY
                // 키보드가 내려가 있을 때의 '전체' 뷰포트 높이를 기준값으로 저장
                if keyboardHeight == 0 { fullContainerHeight = m.container }
            }
            // 당겨서 새로고침 — 공지 본문 + 댓글 둘 다 fresh하게 (병렬).
            // ⚠️ isLoading을 켜면 그 @Published 변경이 뷰 body를 재평가시켜 .refreshable task가 취소되고,
            //    취소된 요청이 에러 alert로 표시된다. → 새로고침은 전체 로딩 오버레이(isLoading)를 끈다.
            .refreshable {
                async let notice: Void = viewModel.loadNotice()
                async let comments: Void = viewModel.loadComments(showLoadingIndicator: false)
                _ = await (notice, comments)
            }

            if !isSystem {
                inputBar
            }
        }
        // SwiftUI 기본 키보드 회피(자동 스크롤/축소)를 끄고, 입력바만 키보드 위 10pt로 직접 올린다.
        // → 입력바가 스크롤 밖이라 포커스해도 위 콘텐츠가 스크롤되지 않음(규칙1: 작으면 그대로).
        .padding(.bottom, keyboardBottomInset)
        .background(Color(uiColor: .bgPrimary))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // 키보드 dismiss는 InteractivePopHostingController의 UIKit tap recognizer가 담당
        .customNavigationBar(title: navigationTitle,
                             isLoading: viewModel.isLoading,
                             trailing: { trailingMenuButton })
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        // 수정 진입 시 자동으로 입력창 포커스 — 일정/리뷰처럼 키보드/전송버튼 즉시 노출
        .onChange(of: viewModel.writeMode) { _, mode in
            if case .edit = mode { inputFocused = true }
        }
        // 입력창 바깥 탭으로 키보드가 내려가면 수정 모드 취소 — 일정/리뷰의 '바깥 탭 취소'와 동일
        // (전송 중에는 취소하지 않아 수정 제출 흐름과 충돌하지 않음)
        .onChange(of: inputFocused) { _, focused in
            if !focused, viewModel.isEditingComment, !viewModel.isSubmitting {
                viewModel.cancelCommentEdit()
            }
        }
        // 키보드 등장: 입력바를 올림(공통). 콘텐츠가 뷰포트보다 클 때만(규칙2) 스크롤도 키보드만큼 올린다.
        // 측정값(contentHeight/fullContainerHeight)이 iOS 18 onScrollGeometryChange 기반이라 작은 콘텐츠에서 오발사 없음(규칙1).
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { note in
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let inset = max(0, frame.height - UIScreen.getNotchSize() + 10)
            let isScrollable = contentHeight > fullContainerHeight + 1

            withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = frame.height }

            guard isScrollable else { return }   // 규칙1: 콘텐츠 작으면 스크롤 그대로
            if savedOffsetY == nil { savedOffsetY = currentOffsetY }
            let target = (savedOffsetY ?? currentOffsetY) + inset
            // 뷰포트가 줄어든(=maxY가 커진) 뒤에 스크롤해야 끝까지 도달한다.
            // 같은 타이밍에 호출하면 '줄기 전' 작은 maxY에 clamp돼 덜 올라가서 마지막 댓글이 잘린다 → 한 틱 미룸.
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.25)) { scrollPosition.scrollTo(y: target) }
            }
        }
        // 키보드 숨김: 입력바 원위치 + (규칙2로 올렸던 경우) 저장한 스크롤 위치로 원복
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = 0 }
            if let saved = savedOffsetY {
                withAnimation(.easeOut(duration: 0.25)) { scrollPosition.scrollTo(y: saved) }
                savedOffsetY = nil
            }
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

    // 시스템 공지는 Mople 앱 로고. 일반 공지는 백엔드 writer의 프로필 이미지를 Kingfisher로 로딩.
    // writer 이미지가 없으면 기본 프로필(.defaultUser)로 폴백.
    @ViewBuilder
    private var authorAvatar: some View {
        if isSystem {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Group {
                if let path = viewModel.notice.writer?.imagePath, let url = URL(string: path) {
                    KFImage(url)
                        .placeholder { Image(.defaultUser).resizable().scaledToFill() }
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(.defaultUser).resizable().scaledToFill()
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
        }
    }

    // 시스템 공지는 "Mople", 일반 공지는 작성자 닉네임(없으면 "모임공지" 폴백)
    private var authorName: String {
        if isSystem { return "Mople" }
        return viewModel.notice.writer?.name ?? "모임공지"
    }

    // MARK: - 댓글 섹션 (custom 전용)
    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("댓글")
                    .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                    .foregroundColor(Color(uiColor: .text01))
                Spacer()
                Text("\(viewModel.totalCount)개")
                    .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                    .foregroundColor(Color(uiColor: .text03))
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 8)

            // 새 댓글 작성 중 로딩 표시 (일정/리뷰의 로딩 셀과 동일하게 상단에 노출, 수정 중에는 표시 안 함)
            if viewModel.isSubmitting && !viewModel.isEditingComment {
                submittingRow
            }

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
                // 마지막(가장 오래된) 댓글이 보이면 다음 페이지 로드
                .onAppear { viewModel.loadMoreIfNeeded(currentItem: comment) }
            }
        }
        .background(Color(uiColor: .bgPrimary))
    }

    // 댓글 작성 중 로딩 셀
    private var submittingRow: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.vertical, 20)
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
        // 입력바는 자기 콘텐츠 높이로 고정(hug) — 내부 TextEditor가 greedy해서 세로로 늘어나는 것을 막는다.
        // 이렇게 해야 남는 세로 공간을 ScrollView가 가져가 입력바 위 빈 공간이 안 생긴다.
        .fixedSize(horizontal: false, vertical: true)
        // 하단은 ChatingTextFieldView와 동일하게 safeArea만 — 추가 padding 없음
        .background(Color(uiColor: .bgPrimary))
    }

    // "댓글 수정중" 뱃지 (UIKit editLabel: 25x70, cornerRadius 4, bgSecondary, Body2.medium, text03)
    // 일정/리뷰 댓글과 동일하게 라벨만 노출 — 취소는 입력창 바깥 탭으로 처리(디자이너 스펙에 취소 버튼 없음)
    private var editLabelRow: some View {
        HStack(spacing: 8) {
            Text("댓글 수정중")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body2))
                .foregroundColor(Color(uiColor: .text03))
                .frame(width: 70, height: 25)
                .background(Color(uiColor: .bgSecondary))
                .cornerRadius(4)
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

// MARK: - 스크롤 측정값 (iOS 18 onScrollGeometryChange용)
private struct ScrollMetrics: Equatable {
    let content: CGFloat
    let container: CGFloat
    let offsetY: CGFloat
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
                    Text(comment.writerName ?? L10n.nonName)
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
                // 일정/리뷰와 동일하게 Kingfisher로 캐싱 로딩
                KFImage(url)
                    .placeholder { Image(.defaultUser).resizable().scaledToFill() }
                    .resizable()
                    .scaledToFill()
            } else {
                Image(.defaultUser).resizable().scaledToFill()
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

