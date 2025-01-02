//
//  CustomTabBar.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

final class DefaultTabBarController: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTabBarFrame()
    }

    private func setupUI() {
        tabBar.backgroundColor = ColorStyle.Default.white
        tabBar.layer.makeLine(width: 1)
        tabBar.layer.makeCornes(radius: 16, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        tabBar.layer.makeShadow(opactity: 0.02,
                                radius: 12)
    }
    
    private func updateTabBarFrame() {
        guard UIScreen.hasNotch() else { return }
        let newHeight: CGFloat = tabBar.frame.height + 10
        var tabFrame = tabBar.frame
        tabFrame.size.height = newHeight
        tabBar.frame = tabFrame
    }
}


