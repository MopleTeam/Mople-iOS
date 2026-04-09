//
//  TransferMeetView.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import SwiftUI

struct TransferMeetView: View {
    
    @StateObject private var viewModel: TransferMeetViewModel
    @State private var selectedMember: MemberInfo?
    @State private var showTransferAlert = false
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFieldFocused: Bool  // 🔥 키보드 포커스 상태 관리
    
    init(viewModel: TransferMeetViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Member List or Empty State (리스트 영역만 차지)
                ZStack {
                    if viewModel.filteredMembers.isEmpty {
                        emptyStateView
                    } else {
                        memberList
                    }
                }
                .frame(maxHeight: .infinity)  // 버튼 위 공간 전체 차지
                .contentShape(Rectangle())
                .onTapGesture {
                    isSearchFieldFocused = false
                }
                
                // Transfer Button (항상 표시)
                transferButton
            }
            .customNavigationBar(title: "모임 양도하기", isLoading: viewModel.isLoading)

            
            // Custom Transfer Alert (네비게이션 바까지 덮음)
            if showTransferAlert, let member = selectedMember {
                TransferConfirmationAlert(
                    member: member,
                    onCancel: {
                        showTransferAlert = false
                    },
                    onConfirm: {
                        if let memberId = member.memberId {
                            viewModel.transferMeet(to: memberId)
                            showTransferAlert = false
                        }
                    }
                )
            }
        }
        .onChange(of: viewModel.shouldDismiss) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(uiColor: .inputIcon))
            
            TextField("닉네임을 검색해주세요", text: $viewModel.searchText)
                .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text01))
                .tint(.text03)
                .focused($isSearchFieldFocused)  // 🔥 포커스 바인딩
                .submitLabel(.search)  // 🔥 키보드 리턴 버튼을 "검색"으로 변경
                .onSubmit {
                    // 🔥 검색 버튼 누르면 키보드 내리기
                    isSearchFieldFocused = false
                }
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(.whiteClose)
                        .foregroundColor(Color(uiColor: .appSecondary))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .bgSecondary))
        .cornerRadius(8)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(uiColor: .bgPrimary))
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(.emptyUser)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("검색 결과가 없어요")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text04))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .bgPrimary))
        .onTapGesture {
            // 🔥 빈 화면 탭 시에도 키보드 내리기
            isSearchFieldFocused = false
        }
    }
    
    // MARK: - Member List
    private var memberList: some View {
        List {
            ForEach(viewModel.filteredMembers, id: \.memberId) { member in
                MemberRowView(
                    member: member,
                    isSelected: selectedMember?.memberId == member.memberId
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(uiColor: .bgPrimary))
                .onTapGesture {
                    // 🔥 멤버 탭 시 키보드 먼저 내리기
                    isSearchFieldFocused = false
                    
                    // 토글 방식: 같은 멤버 클릭 시 해제, 다른 멤버 클릭 시 교체
                    if selectedMember?.memberId == member.memberId {
                        selectedMember = nil  // 해제
                    } else {
                        selectedMember = member  // 선택/교체
                    }
                }
                .onAppear {
                    // 📌 마지막 아이템에 도달하면 다음 페이지 로드
                    if member.memberId == viewModel.filteredMembers.last?.memberId {
                        viewModel.loadMoreMembersIfNeeded()
                    }
                }
            }
            
            // 📌 로딩 인디케이터 (더 불러올 데이터가 있을 때만 표시)
            if viewModel.canLoadMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 8)
                    Spacer()
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color(uiColor: .bgPrimary))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .bgPrimary))
        .scrollDismissesKeyboard(.immediately)  // 🔥 스크롤 시 키보드 즉시 내리기
    }
    
    // MARK: - Transfer Button
    private var transferButton: some View {
        Button {
            showTransferAlert = true
        } label: {
            Text("모임 양도")
                .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(uiColor: selectedMember != nil ? .appPrimary : .disablePrimary))
                .cornerRadius(8)
        }
        .disabled(selectedMember == nil)
        .padding(.horizontal, 20)
        .padding(.bottom, isSearchFieldFocused ? 8 : 0)
        .background(Color(uiColor: .bgPrimary))
    }
}

// MARK: - Member Row View
struct MemberRowView: View {
    let member: MemberInfo
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            AsyncImage(url: URL(string: member.imagePath ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(.defaultUser)
                    .resizable()
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color(uiColor: .appStroke), lineWidth: 1)
            )
            
            // Name
            Text(member.nickname ?? "")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(uiColor: .text01))
                .lineLimit(1)
            
            Spacer()
            
            // Selection Circle
            ZStack {
                // Background Circle (선택 시 배경색)
                if isSelected {
                    Circle()
                        .fill(Color(uiColor: .appBlueGray))
                        .frame(width: 32, height: 32)
                }
                
                // Border
                Circle()
                    .strokeBorder(
                        Color(uiColor: isSelected ? .appPrimary : .appBlueGray),
                        lineWidth: 2
                    )
                    .frame(width: 32, height: 32)
                
                // Checkmark (선택 시)
                if isSelected {
                    Image(uiImage: .check1)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13, height: 10)
                        .foregroundColor(Color(uiColor: .appPrimary))
                }
            }
        }
        .frame(height: 68)
        .background(Color(uiColor: .bgPrimary))
    }
}

// MARK: - Transfer Confirmation Alert
struct TransferConfirmationAlert: View {
    let member: MemberInfo
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            // Dimmed Background (60% opacity)
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            // Alert Content
            VStack(spacing: 24) {
                // 상단: 질문 텍스트
                Text("해당 모임원으로\n모임장을 양도하시겠습니까?")
                    .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                    .foregroundColor(Color(uiColor: .text01))
                    .multilineTextAlignment(.center)
                
                // 중단: 유저 정보
                HStack(spacing: 8) {
                    // Profile Image
                    AsyncImage(url: URL(string: member.imagePath ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(.defaultUser)
                            .resizable()
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(uiColor: .appStroke), lineWidth: 1)
                    )
                    
                    // Nickname
                    Text(member.nickname ?? "")
                        .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.body1))
                        .foregroundColor(Color(uiColor: .text01))
                        .lineLimit(1)
                }
                .padding(.all, 12)
                .background(Color(uiColor: .bgSecondary))
                .cornerRadius(999)
                
                // 하단: 버튼들
                HStack(spacing: 8) {
                    // 아니요 버튼
                    Button {
                        onCancel()
                    } label: {
                        Text("아니요")
                            .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                            .foregroundColor(Color(uiColor: .tertiaryText))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(uiColor: .appTertiary))
                            .cornerRadius(8)
                    }
                    
                    // 네 버튼
                    Button {
                        onConfirm()
                    } label: {
                        Text("네")
                            .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                            .foregroundColor(.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(uiColor: .appPrimary))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(.bgPrimary)
            .cornerRadius(12)
            .padding(.horizontal, 27.5)
        }
    }
}

// MARK: - Preview
#Preview {
    let mockMeet = Meet(
        meetSummary: MeetSummary(id: 1, name: "테스트 모임"),
        sinceDays: 10,
        creatorId: 1,
        memberCount: 5,
        firstPlanDate: nil
    )
    
    let mockFetchMemberUseCase = MockFetchMemberUseCase()
    let mockTransferUseCase = MockTransferMeetUseCase()
    
    let viewModel = TransferMeetViewModel(
        meet: mockMeet,
        fetchMemberListUseCase: mockFetchMemberUseCase,  // ✅ Mock 주입
        transferUseCase: mockTransferUseCase
    )
    
    NavigationStack {
        TransferMeetView(viewModel: viewModel)
    }
}

