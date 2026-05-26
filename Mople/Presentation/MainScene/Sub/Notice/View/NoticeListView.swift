//
//  NoticeListView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import SwiftUI

// Phase 1 placeholder. 본 화면은 후속 PR에서 SwiftUI + @Observable + async/await 으로 구현.
// 확성기 버튼에서 진입. 작성 진입점은 isCreator일 때만 노출 예정.
struct NoticeListView: View {

    let meetId: Int
    let isCreator: Bool
    let onComposeTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("공지 리스트 화면 (구현 예정)")
                .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                .foregroundColor(Color(uiColor: .text01))
            Text("meetId: \(meetId)")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text03))
            Text("isCreator: \(String(isCreator))")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text03))

            if isCreator {
                Button(action: onComposeTap) {
                    Text("공지 작성하기")
                        .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.body1))
                        .foregroundColor(Color(uiColor: .primaryText))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(uiColor: .appPrimary))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .bgPrimary))
        .customNavigationBar(title: "공지사항")
    }
}
