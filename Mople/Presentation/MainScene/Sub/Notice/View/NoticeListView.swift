//
//  NoticeListView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import SwiftUI
import Domain

// 확성기 버튼에서 진입하는 공지 리스트.
// 상단 세그먼트(전체/모임공지/시스템)는 로컬 필터링이며 API는 1회 호출.
// 우상단 작성(연필) 아이콘은 모임장에게만 노출.
// 모임장은 셀을 leading swipe하면 파란 핀 버튼이 드러나며 탭하면 pin/unpin API 호출.
// 모임원에게는 swipe action 자체가 노출되지 않는다.
struct NoticeListView: View {

    @StateObject private var viewModel: NoticeListViewModel
    // 세그먼트 언더라인이 탭 사이를 슬라이드 이동하도록 matchedGeometryEffect 네임스페이스
    @Namespace private var segmentNamespace

    init(viewModel: NoticeListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            filterSegment
            content
        }
        .background(Color(uiColor: .bgPrimary))
        .customNavigationBar(title: "공지사항",
                             isLoading: viewModel.isLoading,
                             onBack: { viewModel.dismissFlow() },
                             trailing: {
            if viewModel.isCreator {
                Button(action: { viewModel.tapCompose() }) {
                    Image(.pencil)
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 40, height: 40)
            }
        })
        .alert("오류", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - 세그먼트 (밑줄 스타일 + 슬라이드 애니메이션)
    // matchedGeometryEffect로 선택된 탭의 언더라인을 하나만 두고 SwiftUI가 자동으로 위치 보간
    private var filterSegment: some View {
        HStack(spacing: 0) {
            ForEach(NoticeListViewModel.Filter.allCases, id: \.rawValue) { filter in
                let isSelected = viewModel.selectedFilter == filter
                Text(filter.title)
                    .font(.custom(isSelected ? FontFamily.Pretendard.semiBold : FontFamily.Pretendard.regular,
                                  size: FontStyle.Size.body1))
                    .foregroundColor(Color(uiColor: .text02))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        // 선택된 탭에만 underline을 두고 같은 id로 matchedGeometryEffect 연결
                        // → 다른 탭을 탭하면 SwiftUI가 위치를 보간해 검은 바가 슬라이드 이동
                        if isSelected {
                            Rectangle()
                                .fill(Color(uiColor: .appSecondary))
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "segmentUnderline",
                                                       in: segmentNamespace)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            viewModel.selectedFilter = filter
                        }
                    }
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 8)
        .background(Color(uiColor: .bgPrimary))
    }

    // MARK: - 본문
    @ViewBuilder
    private var content: some View {
        if viewModel.filteredNotices.isEmpty && !viewModel.isLoading {
            Color(uiColor: .bgPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // List를 쓰는 이유: SwiftUI `.swipeActions`가 List 셀에서만 동작.
            // 디자인은 카드형이 아니라 흰 row + hairline이라 listRowInsets/Separator를 직접 제어.
            List {
                ForEach(viewModel.filteredNotices, id: \.noticeId) { notice in
                    NoticeListRow(notice: notice)
                        .contentShape(Rectangle())
                        .onTapGesture { viewModel.selectNotice(notice) }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(uiColor: .bgPrimary))
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            if viewModel.isCreator {
                                Button {
                                    viewModel.togglePin(notice)
                                } label: {
                                    // 라벨에 직접 .doAnchor를 못 받아서 systemImage placeholder를 두고
                                    // tint로 배경색만 분기. (실제 이미지는 placeholder가 보임)
                                    // 정확한 .doAnchor 이미지 + 배경색 적용을 위해 Label 대신 VStack 사용 가능하지만,
                                    // SwiftUI .swipeActions는 systemImage만 정식 지원이라 placeholder 유지 + tint 분기.
                                    Label(notice.isPinned ? "고정해제" : "고정",
                                          image: ImageResource.doAnchor)
                                }
                                // 고정 요청 시 .appPrimary, 해제 시 .appRed
                                .tint(notice.isPinned ? Color(uiColor: .appRed) : Color(uiColor: .appPrimary))
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .bgPrimary))
            .refreshable {
                await viewModel.loadInitial()
            }
        }
    }
}

// MARK: - Row (피그마 4206-3611 기준)
// 흰 배경 + 하단 hairline.
// 좌측 아이콘 구성:
//   - 고정(pinned) 공지: anchor(24×24) + 타입 아이콘
//   - 그 외: 타입 아이콘만
// 타입 아이콘: .custom → megaphone, .system → system
// 모임장은 leading swipe로 핀 토글 가능.
private struct NoticeListRow: View {
    let notice: Notice

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            leadingIcons
            textColumn
                .padding(.leading, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .bgPrimary))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(uiColor: .appStroke))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private var leadingIcons: some View {
        if notice.isPinned {
            Image(.anchor)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        Image(typeIconResource)
            .resizable()
            .scaledToFit()
            // 피그마: 24 컨테이너에 20 아이콘
            .frame(width: 20, height: 20)
            .frame(width: 24, height: 24)
    }

    private var typeIconResource: ImageResource {
        switch notice.type {
        case .system: return .system
        case .custom, .none: return .megaphone
        }
    }

    private var textColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 본문 (1줄 말줄임)
            Text(notice.content ?? "")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text02))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 메타 라인: 절대시간 · 상대시간 (· 읽음수는 데이터 들어올 때만)
            HStack(spacing: 4) {
                ForEach(Array(metaParts.enumerated()), id: \.offset) { idx, part in
                    if idx > 0 {
                        Text("·")
                            .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body2))
                            .foregroundColor(Color(uiColor: .text03))
                    }
                    Text(part)
                        .font(.custom(FontFamily.Pretendard.regular, size: FontStyle.Size.body2))
                        .foregroundColor(Color(uiColor: .text03))
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var metaParts: [String] {
        var parts: [String] = []
        if let date = notice.createdAt {
            parts.append(NoticeDateFormatter.absolute(from: date))
            parts.append(NoticeDateFormatter.relative(from: date))
        }
        // "N명 읽음" — 서버 응답에 readCount가 추가되면 여기서 append
        return parts
    }
}

// MARK: - Date Helpers
// 공지 리스트 메타 라인 전용. 피그마 표기 ("11월 28일 오후 2:00", "34분 전") 매칭.
enum NoticeDateFormatter {
    private static let absoluteFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 a h:mm"
        return f
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.unitsStyle = .short
        return f
    }()

    static func absolute(from date: Date) -> String {
        return absoluteFormatter.string(from: date)
    }

    static func relative(from date: Date, now: Date = Date()) -> String {
        // RelativeDateTimeFormatter는 미래 기준이면 "후"가 붙는데
        // 공지는 무조건 과거이므로 음수 시간으로 강제 전달
        let interval = date.timeIntervalSince(now)
        let safeInterval = min(interval, -1) // 미래일 경우 1초 전으로 클램프
        let raw = relativeFormatter.localizedString(fromTimeInterval: safeInterval)
        return raw
    }
}
