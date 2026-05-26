//
//  NoticeDetailView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import SwiftUI

// Phase 1 placeholder. 미리보기 카드에서 진입.
struct NoticeDetailView: View {

    let noticeId: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("공지 상세 화면 (구현 예정)")
                .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                .foregroundColor(Color(uiColor: .text01))
            Text("noticeId: \(noticeId)")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text03))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .bgPrimary))
        .customNavigationBar(title: "공지 상세")
    }
}
