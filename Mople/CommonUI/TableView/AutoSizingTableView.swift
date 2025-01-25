//
//  AutoReSizingTableView.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//

import UIKit

final class AutoSizingTableView: UITableView {

    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    override var contentSize: CGSize {
        didSet {
            print(#function, #line, "Path : # 55 ")
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
