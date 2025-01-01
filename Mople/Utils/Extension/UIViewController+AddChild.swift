//
//  UIViewController+Ext.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import SnapKit

extension UIViewController {
    func add(child: UIViewController, container: UIView) {
        addChild(child)
        container.addSubview(child.view)
        child.didMove(toParent: self)
        child.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func remove() {
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
