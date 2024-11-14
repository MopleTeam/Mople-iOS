//
//  AppAppearance.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import Foundation
import UIKit

final class AppAppearance {
    
    static func setupAppearance() {
        setupTabBarAppearance()
    }
    
    private static func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: ColorStyle.Gray._05,
                                                                         .font: FontStyle.App.tabbar]
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
        appearance.stackedLayoutAppearance.normal.iconColor = ColorStyle.App.icon
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: ColorStyle.App.secondary,
                                                                           .font: FontStyle.App.tabbar]
        appearance.stackedLayoutAppearance.selected.iconColor = ColorStyle.App.secondary
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}



