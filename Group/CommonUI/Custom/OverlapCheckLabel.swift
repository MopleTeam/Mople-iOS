//
//  OverlapCheckLabel.swift
//  Group
//
//  Created by CatSlave on 10/17/24.
//
import RxSwift
import RxCocoa
import UIKit

final class OverlapCheckLabel: BaseLabel {
    
    init() {
        super.init(configure: AppDesign.Profile.checkLabel)
        isHidden = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func overlapCheck(_ isOverlap: Bool) {
        if isOverlap {
            setConfigure(AppDesign.Profile.overlapTitle)
        } else {
            setConfigure(AppDesign.Profile.nonOverlapTitle)
        }
    }
    
    private func setConfigure(_ configure: UIConstructive) {
        self.text = configure.itemConfig.text
        self.textColor = configure.itemConfig.color
    }
}

extension Reactive where Base: OverlapCheckLabel {
    var isOverlap: Binder<Bool> {
        return Binder(self.base) { label, isOverlap in
            label.isHidden = false
            label.overlapCheck(isOverlap)
        }
    }
}
