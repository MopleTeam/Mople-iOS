//
//  CustomTabBar.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

final class MainTabBarController: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTabBarFrame()
    }

    private func setupUI() {
        tabBar.backgroundColor = AppDesign.defaultWihte
        tabBar.layer.makeLine(width: 1)
        tabBar.layer.makeCornes(radius: 18, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        tabBar.layer.makeShadow(CGSize(width: 0, height: -4))
    }
    
    private func updateTabBarFrame() {
        guard UIScreen.isNotch() else { return }
        let newHeight: CGFloat = tabBar.frame.height + 10
        var tabFrame = tabBar.frame
        tabFrame.size.height = newHeight
        tabBar.frame = tabFrame
    }
}



