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
    }
    
    private static func setupNavigationBarAppearance() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.backgroundColor = .white
            appearance.shadowColor = .clear
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = .black
            UINavigationBar.appearance().tintColor = .black
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
    }

}

extension UINavigationController {
    @objc override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}

