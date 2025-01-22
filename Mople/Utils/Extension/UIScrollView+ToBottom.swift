//
//  UIScrollView+ToBottom.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import UIKit

extension UIScrollView {

    func scrollToBottom(animated: Bool) {
        let calculateOffsetY = contentSize.height - bounds.size.height + contentInset.bottom
        print(#function, #line, "Path : # 55 \(calculateOffsetY)")
        guard calculateOffsetY > 0 else { return }
        setContentOffset(.init(x: 0,
                               y: calculateOffsetY),
                         animated: animated)
    }
}
