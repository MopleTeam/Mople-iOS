//
//  UITableView+ResizeHeader.swift
//  Mople
//
//  Created by CatSlave on 5/12/25.
//

import UIKit

extension UITableView {
    /// tableHeaderView의 Auto Layout 기반 높이를 자동 갱신합니다.
    func resizeHeaderView() {
        if let headerView = tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableHeaderView = headerView
            }
        }
        self.layoutIfNeeded()
    }
}
