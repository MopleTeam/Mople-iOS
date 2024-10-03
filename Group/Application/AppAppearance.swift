//
//  AppAppearance.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import Foundation
import UIKit

#warning("custom 네비로 사용하지 않음")
final class AppAppearance {
    
    static func setupAppearance() {
        setupNavigationBarAppearance()
        setupTabBarAppearance()
    }
    
    private static func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.init(hexCode: "3E3F40"), .font: UIFont.pretendard(type: .semiBold, size: 10)]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.font: UIFont.pretendard(type: .semiBold, size: 10)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private static func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

