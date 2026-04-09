//
//  CustomNavigationBar.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import SwiftUI

// MARK: - Custom Navigation Bar (UIKit TitleNaviBar 스타일)
struct CustomNavigationBar: View {
    let title: String
    let isLoading: Bool
    let onBackTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Status Bar 영역 (notchView)
            Color(uiColor: .bgPrimary)
                .frame(height: UIScreen.getTopNotchSize())
            
            // Navigation Bar (TitleNaviBar 스타일, 56pt 높이)
            HStack(spacing: 0) {
                // Left Button Container (40pt)
                Button(action: onBackTapped) {
                    Image(uiImage: .backArrow)  // UIKit과 동일한 이미지
                        .renderingMode(.template)
                        .foregroundColor(Color(uiColor: .appSecondary))
                }
                .frame(width: 40, height: 40)
                .padding(.leading, 20)  // mainStackView horizontalEdges inset 20
                .disabled(isLoading)  // 로딩 중에는 뒤로가기 비활성화
                
                Spacer()
                Text(title)
                    .font(.custom(FontFamily.Pretendard.bold.name, size: FontStyle.Size.title2))
                    .foregroundColor(Color(uiColor: .text01))
                
                Spacer()
                
                // Right Button Container (40pt) - 빈 공간으로 타이틀 센터 정렬
                Color.clear
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 20)  // mainStackView horizontalEdges inset 20
            }
            .frame(height: 56)  // TitleNaviBar 높이
            .background(Color(uiColor: .bgPrimary))
        }
        .ignoresSafeArea(edges: .top)
    }
}


// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

// MARK: - Custom Navigation Bar Modifier
struct CustomNavigationBarModifier: ViewModifier {
    let title: String
    let isLoading: Bool
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        ZStack {
            VStack(spacing: 0) {  // spacing: 0 확인
                CustomNavigationBar(title: title, isLoading: isLoading) {
                    dismiss()
                }
                
                content  // ← 여기에 List가 들어옴
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .top)  // 🔥 modifier 레벨에서 ignoresSafeArea
            
            // 로딩 오버레이 (전체 화면을 덮음)
            if isLoading {
                LoadingView()
            }
        }
    }
}



extension View {
    func customNavigationBar(title: String, isLoading: Bool = false) -> some View {
        modifier(CustomNavigationBarModifier(title: title, isLoading: isLoading))
    }
}
// MARK: - Preview
#Preview {
    CustomNavigationBar(title: "타이틀", isLoading: false) {
        print("Back button tapped")
    }
}

#Preview("With Content") {
    VStack(spacing: 0) {
        CustomNavigationBar(title: "설정", isLoading: false) {
            print("Back button tapped")
        }
        
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<20) { index in
                    Text("Content Row \(index)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
    .ignoresSafeArea(edges: .top)
}

