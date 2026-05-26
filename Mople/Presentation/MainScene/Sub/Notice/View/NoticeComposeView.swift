//
//  NoticeComposeView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import SwiftUI
import Domain

// 공지 작성 화면. 모임장만 진입 가능 (리스트의 우상단 연필 아이콘).
// 키보드 처리:
//  - 화면 빈 영역 탭 시 키보드 내림 (포커스 해제)
//  - 키보드 올라오면 "작성 완료" 버튼이 키보드 위로 따라옴 (SwiftUI 기본 keyboard avoidance)
//  - TextEditor는 남는 공간 전체를 차지하며 콘텐츠가 길어지면 자체 스크롤
//  - 본문 길이는 500자에서 컷 (붙여넣기로 들어와도 prefix로 자름)
struct NoticeComposeView: View {

    @StateObject private var viewModel: NoticeComposeViewModel
    @FocusState private var editorFocused: Bool

    init(viewModel: NoticeComposeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            editor
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
            submitButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // VStack 빈 영역 탭으로 키보드 내림. background에 contentShape를 줘야 빈 영역 hit testing 됨.
        .background(
            Color(uiColor: .bgPrimary)
                .contentShape(Rectangle())
                .onTapGesture { editorFocused = false }
        )
        .customNavigationBar(title: viewModel.navigationTitle,
                             isLoading: viewModel.isSubmitting,
                             onBack: { viewModel.dismissFlow() })
        .onAppear { editorFocused = true }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            // 입력 박스 배경
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .bgInput))

            // Placeholder — 입력이 비었을 때만 표시. allowsHitTesting(false)로 TextEditor 탭 방해 금지.
            if viewModel.content.isEmpty {
                Text("멤버들에게 공지를 남겨보세요.")
                    .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body1))
                    .foregroundColor(Color(uiColor: .text03))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .allowsHitTesting(false)
            }

            // 실제 입력. maxHeight: .infinity로 두면 키보드 avoidance에 따라 자동으로 줄어듦.
            TextEditor(text: $viewModel.content)
                .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text01))
                .focused($editorFocused)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.visible)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onChange(of: viewModel.content) { newValue in
                    // 500자 초과 시 자름 (붙여넣기 대응)
                    if newValue.count > viewModel.maxLength {
                        viewModel.content = String(newValue.prefix(viewModel.maxLength))
                    }
                }
        }
        // editor가 가용 공간 전체를 채우게 → button이 키보드 따라 올라오면 editor가 자동 축소
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var submitButton: some View {
        Button(action: {
            editorFocused = false
            viewModel.submit()
        }) {
            Text(viewModel.submitButtonTitle)
                .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                .foregroundColor(Color(uiColor: viewModel.canSubmit ? .primaryText : .disableText))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(uiColor: viewModel.canSubmit ? .appPrimary : .disablePrimary))
                .cornerRadius(8)
        }
        .disabled(!viewModel.canSubmit)
        .padding(.horizontal, 20)
        // 키보드 안 떴을 때 safeArea 아래 약간 띄움, 떴을 때는 avoidance가 위로 밀어줌
        .padding(.bottom, 8)
    }
}
