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
        setupNavigationBarAppearance()
        setupTabBarAppearance()
    }
    
    private static func setupNavigationBarAppearance() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.backgroundColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = .black
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
    
    private static func setupTabBarAppearance() {
         if #available(iOS 15, *) {
             let appearance = UITabBarAppearance()
             appearance.configureWithOpaqueBackground()
             appearance.backgroundColor = .white
             
             UITabBar.appearance().standardAppearance = appearance
             UITabBar.appearance().scrollEdgeAppearance = appearance
         } else {
             UITabBar.appearance().barTintColor = .systemBackground
             UITabBar.appearance().tintColor = .systemBlue
         }
         
         // 공통 설정
         UITabBar.appearance().unselectedItemTintColor = .gray
     }
}

extension UINavigationController {
    @objc override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
