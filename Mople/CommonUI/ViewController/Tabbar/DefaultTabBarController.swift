//
//  CustomTabBar.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit
import SnapKit

final class DefaultTabBarController: UITabBarController {
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.App.stroke
        view.layer.makeCornes(radius: 16, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        return view
    }()
    
    private let mainBackView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.Default.white
        view.layer.makeCornes(radius: 16, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        return view
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        print(#function, #line, "LifeCycle Test DefaultTabBarController Created" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultTabBarController Deinit" )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTabBarFrame()
    }

    private func setupUI() {
        self.tabBar.addSubview(borderView)
        self.tabBar.addSubview(mainBackView)
        mainBackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        borderView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(tabBar)
            make.bottom.equalTo(tabBar)
            make.top.equalTo(tabBar).offset(-1)
        }
    }
    
    private func setTabBar() {
        tabBar.clipsToBounds = false
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

extension DefaultTabBarController {
    func viewcController<T: UIViewController>(ofType type: T.Type) -> T? {
        let navs = viewControllers as? [UINavigationController] ?? []

        for nav in navs {
            if let matched = nav.viewControllers.first(where: { $0 is T }) as? T {
                return matched
            }
        }
        
        return nil
    }
}
