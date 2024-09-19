//
//  CustomTabBar.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

final class CustomTabBarController: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTabBarFrame()
    }

    private func setupUI() {
        tabBar.backgroundColor = .white
        tabBar.isTranslucent = true
        tabBar.layer.cornerRadius = 18
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor(hexCode: "F2F2F2").cgColor
//        tabBar.layer.shadowOpacity = 0.5
//        tabBar.layer.shadowRadius = 18
//        tabBar.layer.shadowColor = UIColor.black.cgColor//UIColor(hexCode: "F2F2F2").cgColor
//        tabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tabBar.items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -5.0) })
    }

    
//    self.layer.cornerRadius = 8
//    self.layer.shadowRadius = 8
//    self.layer.shadowOpacity = 0.5
//    self.layer.shadowColor = UIColorSet.background(.shadow).cgColor
//    self.layer.shadowOffset = CGSize(width: 2, height: 2)
    
    
    private func updateTabBarFrame() {
        let newHeight: CGFloat = 65 + UIScreen.bottomSafeArea
        var tabFrame = tabBar.frame
        tabFrame.size.height = newHeight
        tabFrame.origin.y = view.frame.size.height - newHeight
        tabBar.frame = tabFrame
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        return UIApplication.shared
            .connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}

extension UIScreen {
    static var bottomSafeArea: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    }
}
