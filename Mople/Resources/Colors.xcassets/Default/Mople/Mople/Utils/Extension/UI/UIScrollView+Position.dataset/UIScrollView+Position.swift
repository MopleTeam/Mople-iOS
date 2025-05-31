//
//  UIScrollView+ToBottom.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import UIKit

extension UIScrollView {
    
    var contentOffsetMaxY: CGFloat {
        let bottomInset = contentInset.bottom
        let boundsHeight = bounds.height
        let contentOffsetY = contentOffset.y
        return contentOffsetY + bottomInset + min(boundsHeight, contentSize.height)
    }
    
    var contentHeight: CGFloat {
        return contentSize.height.rounded(.down)
    }
    
    func isBottom(threshold: CGFloat = 0) -> Bool {
        return contentHeight <= contentOffsetMaxY + threshold
    }
    
    func isRefresh(threshold: CGFloat = -60) -> Bool {
        let contentOffsetY = contentOffset.y
        return contentOffsetY < threshold
    }
    
    func isCenter() -> Bool {
        let halfContentHeight = contentHeight / 2
        return halfContentHeight < contentOffsetMaxY
    }

    func scrollToBottom(animated: Bool) {
        let calculateOffsetY = contentSize.height - bounds.size.height + contentInset.bottom
        guard calculateOffsetY > 0 else { return }
        setContentOffset(.init(x: 0,
                               y: calculateOffsetY),
                         animated: animated)
    }
}
