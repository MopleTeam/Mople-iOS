//
//  NoticeComposeView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import SwiftUI

// Phase 1 placeholder. 공지 리스트 화면의 작성 버튼에서만 진입. 모임장만.
struct NoticeComposeView: View {

    let meetId: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("공지 작성 화면 (구현 예정)")
                .font(.custom(FontFamily.Pretendard.semiBold, size: FontStyle.Size.title3))
                .foregroundColor(Color(uiColor: .text01))
            Text("meetId: \(meetId)")
                .font(.custom(FontFamily.Pretendard.medium, size: FontStyle.Size.body1))
                .foregroundColor(Color(uiColor: .text03))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .bgPrimary))
        .customNavigationBar(title: "공지 작성")
    }
}
