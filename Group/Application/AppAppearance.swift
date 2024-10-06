//
//  AppAppearance.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import Foundation
import UIKit

#warning("custom 네비로 사용하지 않음 네비 부분 삭제 예정")
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
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: AppDesign.TabBar.titleColor, .font: AppDesign.TabBar.titleFont]
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
        appearance.stackedLayoutAppearance.normal.iconColor = AppDesign.TabBar.normalColor
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: AppDesign.TabBar.selectedColor, .font: AppDesign.TabBar.titleFont]
        appearance.stackedLayoutAppearance.selected.iconColor = AppDesign.TabBar.selectedColor
        
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



