//
//  UIViewController+Ext.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit

extension UIViewController {
    
    func add(child: UIViewController, container: UIView) {
        addChild(child)
        child.view.frame = container.bounds
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }
}
