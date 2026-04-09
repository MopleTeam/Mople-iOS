//
//  TransferMeetListView.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import SwiftUI

struct TransferMeetListView: View {

    @StateObject private var viewModel: TransferMeetListViewModel
    @State private var showDeleteConfirm = false

    init(viewModel: TransferMeetListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 안내 문구
            Text("모임장을 양도하지 않고\n탈퇴하면 모임이 사라져요")
                .font(.custom(FontFamily.Pretendard.bold, size: FontStyle.Size.heading))
                .foregroundColor(Color(uiColor: .text01))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(uiColor: .bgPrimary))
            
            // Meet List
            ZStack {
                if viewModel.transferableMeets.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    meetList
                }
            }
            .frame(maxHeight: .infinity)
            
            // Delete Account Button (하단 고정)
            deleteAccountButton
        }
      
        .customNavigationBar(title: "모임 양도", isLoading: viewModel.isLoading, onBack: {
            viewModel.dismissFlow()
        })
      
        .overlay {
            if showDeleteConfirm {
                DeleteAccountConfirmAlert(
                    onCancel: { showDeleteConfirm = false },
                    onConfirm: {
                        showDeleteConfirm = false
                        viewModel.proceedToDeleteAccount()
                    }
                )
            }
        }
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(.emptyGroup)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("양도할 모임이 없어요")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text02))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .bgSecondary))
    }
    
    // MARK: - Meet List
    private var meetList: some View {
        List {
            // 헤더: 양도 가능한 모임 / 갯수
            HStack {
                Text("양도 가능한 모임")
                    .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                    .foregroundColor(Color(uiColor: .text03))
                
                Spacer()
                
                Text("\(viewModel.transferableMeets.count)개")
                    .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                    .foregroundColor(Color(uiColor: .text03))
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 16)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ForEach(viewModel.transferableMeets, id: \.meetSummary?.id) { meet in
                TransferMeetListCell(
                    meet: meet,
                    isTransferred: viewModel.isTransferred(meet: meet),
                    onTransferTap: {
                        // 양도하기 화면으로 이동
                        viewModel.selectMeetForTransfer(meet)
                    }
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onAppear {
                    // 마지막 아이템에 도달하면 다음 페이지 로드
                    if meet.meetSummary?.id == viewModel.transferableMeets.last?.meetSummary?.id {
                        viewModel.loadMoreMeetsIfNeeded()
                    }
                }
            }
            
            // 로딩 인디케이터 (더 불러올 데이터가 있을 때만 표시)
            if viewModel.canLoadMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, 8)
                    Spacer()
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .bgSecondary))
    }
    
    // MARK: - Delete Account Button
  
    private var deleteAccountButton: some View {
        Text("탈퇴하기")
            .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
            .foregroundColor(.primaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(uiColor: .appSecondary))
            .cornerRadius(8)
            .contentShape(Rectangle())  // 탭 영역 확보
            .onTapGesture {
                showDeleteConfirm = true
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            .background(Color(uiColor: .bgSecondary))
    }
}

// MARK: - Transfer Meet List Cell
struct TransferMeetListCell: View {
    let meet: Meet
    let isTransferred: Bool
    let onTransferTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // 상단: 모임 정보 (MeetListTableCell 참고)
            HStack(spacing: 12) {
                // Thumbnail
                AsyncImage(url: URL(string: meet.meetSummary?.imagePath ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(.defaultMeet)
                        .resizable()
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(uiColor: .appStroke), lineWidth: 1)
                )
                
                // 모임 정보
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        // 모임 이름
                        Text(meet.meetSummary?.name ?? "")
                            .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                            .foregroundColor(Color(uiColor: .text01))
                            .lineLimit(1)
                        
                        Image(.owner)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                    
                    // 멤버 수
                    HStack(spacing: 4) {
                        Image("member")
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(uiColor: .text03))
                        
                        Text("\(meet.memberCount ?? 0)명")
                            .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body2))
                            .foregroundColor(Color(uiColor: .text03))
                    }
                }
                
                Spacer()
            }
            transferButton
        }
        .padding(16)
        .background(Color(uiColor: .bgPrimary))
        .cornerRadius(12)
    }
    
    // MARK: - Schedule Label
    private var scheduleLabel: some View {
        Text(scheduleText)
            .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
            .foregroundColor(Color(uiColor: .text03))
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .bgInput))
            .cornerRadius(10)
    }
    
    private var scheduleText: String {
        guard let date = meet.firstPlanDate else {
            return "새로운 일정을 만들어보세요"
        }
        
        let days = DateManager.numberOfDaysBetween(date)
        
        switch days {
        case 0:
            return "오늘 일정이 있어요"
        case 1...:
            return "D-\(days) 일정이 있어요"
        case ...(-1):
            return "마지막 일정 \(abs(days))일 전"
        default:
            return "새로운 일정을 만들어보세요"
        }
    }
    
    // MARK: - Transfer Button
    private var transferButton: some View {
        Text("모임 양도하기")
            .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.body1))
            .foregroundColor(Color(uiColor: .text02))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(uiColor: .appTertiary))
            .cornerRadius(10)
            .contentShape(Rectangle())
            .onTapGesture {
                if !isTransferred {
                    onTransferTap()
                }
            }
    }
}

// MARK: - 탈퇴 확인 커스텀 알림 (UIKit DefaultAlertViewController 디자인 차용)
struct DeleteAccountConfirmAlert: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            // 딤 배경 (60% opacity, 탭하면 닫힘)
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            // 알림 콘텐츠
            VStack(spacing: 24) {
                // 타이틀 + 서브타이틀
                VStack(spacing: 8) {
                    Text(L10n.Profile.resignInfo)
                        .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                        .foregroundColor(Color(uiColor: .text01))
                        .multilineTextAlignment(.center)

                    Text(L10n.Profile.resignSubInfo)
                        .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                        .foregroundColor(Color(uiColor: .text03))
                        .multilineTextAlignment(.center)
                }

                // 버튼 (취소 + 탈퇴)
                HStack(spacing: 8) {
                    Button { onCancel() } label: {
                        Text(L10n.no)
                            .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                            .foregroundColor(Color(uiColor: .tertiaryText))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(uiColor: .appTertiary))
                            .cornerRadius(8)
                    }

                    Button { onConfirm() } label: {
                        Text(L10n.Profile.resign)
                            .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                            .foregroundColor(Color(uiColor: .secondaryText))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(uiColor: .appSecondary))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .bgPrimary))
            .cornerRadius(12)
            .padding(.horizontal, 27.5)
        }
    }
}

// MARK: - Preview
#if DEV
#Preview {
    let mockFetchUseCase = MockFetchMyHostMeetsUseCase()
    let mockDeleteUseCase = MockDeleteAccountUseCase()
    let viewModel = TransferMeetListViewModel(
        fetchMyHostMeetsUseCase: mockFetchUseCase,
        deleteAccountUseCase: mockDeleteUseCase
    )

    return TransferMeetListView(viewModel: viewModel)
}
#endif
