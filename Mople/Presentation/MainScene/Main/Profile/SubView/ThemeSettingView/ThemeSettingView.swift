//
//  ThemeSettingView.swift
//  Mople
//
//  Created by CatSlave on 4/9/26.
//

import SwiftUI
import Domain

/// 테마 설정 옵션
enum ThemeMode: Int, CaseIterable {
    case light = 0
    case dark = 1
    case system = 2

    var title: String {
        switch self {
        case .light: return "라이트 모드"
        case .dark: return "다크 모드"
        case .system: return "시스템 설정"
        }
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
}

struct ThemeSettingView: View {

    @State private var selectedMode: ThemeMode

    init() {
        let savedValue = UserDefaults.standard.integer(forKey: "appThemeMode")
        _selectedMode = State(initialValue: ThemeMode(rawValue: savedValue) ?? .system)
    }

    var body: some View {
        VStack(spacing: 0) {
            themeOptionList
            Spacer()
        }
        .background(Color(uiColor: .bgPrimary))
        .customNavigationBar(title: "화면 테마")
    }
}

// MARK: - Theme Option List
extension ThemeSettingView {
    private var themeOptionList: some View {
        VStack(spacing: 0) {
            ForEach(ThemeMode.allCases, id: \.self) { mode in
                themeOptionRow(mode: mode)
            }
        }
        .padding(.horizontal, 20)
    }

    private func themeOptionRow(mode: ThemeMode) -> some View {
        Button(action: { selectTheme(mode) }) {
            HStack {
                Text(mode.title)
                    .font(.custom(FontFamily.Pretendard.medium,
                                  size: FontStyle.Size.title3))
                    .foregroundStyle(Color(uiColor: .text01))

                Spacer()

                radioButton(isSelected: selectedMode == mode)
            }
            .frame(height: 56)
        }
    }

    private func radioButton(isSelected: Bool) -> some View {
        ZStack {
            // 선택 시 배경색
            if isSelected {
                Circle()
                    .fill(Color(uiColor: .appBlueGray))
                    .frame(width: 32, height: 32)
            }

            // 테두리
            Circle()
                .strokeBorder(
                    Color(uiColor: isSelected ? .appPrimary : .appBlueGray),
                    lineWidth: 2
                )
                .frame(width: 32, height: 32)

            // 체크마크 (선택 시)
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
}

// MARK: - Theme Apply
extension ThemeSettingView {
    /// 테마 선택 시 UserDefaults 저장 + 앱 전체 즉시 적용
    private func selectTheme(_ mode: ThemeMode) {
        selectedMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "appThemeMode")

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = mode.userInterfaceStyle
        }
    }
}
