//
//  OverlapCheckLabel.swift
//  Group
//
//  Created by CatSlave on 10/17/24.
//
import UIKit
import RxSwift

final class DuplicateLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupDefault()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDefault() {
        isHidden = true
        font = FontStyle.Body1.regular
    }
    
    fileprivate func updateText(_ isOverlap: Bool) {
        text = isOverlap ? TextStyle.ProfileSetup.duplicateText : TextStyle.ProfileSetup.validateTitle
        textColor = isOverlap ? ColorStyle.Default.red : ColorStyle.Default.green
    }
}

extension Reactive where Base: DuplicateLabel {
    var isOverlap: Binder<Bool> {
        return Binder(self.base) { label, isOverlap in
            label.isHidden = false
            label.updateText(isOverlap)
        }
    }
}


