//
//  NavigationBarExtendable.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import SnapKit

protocol NavigationBarExtendable: AnyObject {
    func setupExtendedNavigationBar()
}

extension NavigationBarExtendable where Self: UIViewController {
    
    private var extendedNavBarView: UIView {
//         if let existingView = view.viewWithTag(100) { // 임의의 태그 번호
//             return existingView
//         }
         let view = UIView()
         view.backgroundColor = .white
         view.tag = 100 // 임의의 태그 번호
         return view
     }
    
    func setupExtendedNavigationBar() {
        self.view.addSubview(extendedNavBarView)
        
        extendedNavBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(12)
        }
    }
}
