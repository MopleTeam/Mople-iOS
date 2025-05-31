//
//  CustomCalendarCell.swift
//  Group
//
//  Created by CatSlave on 9/13/24.
//

import UIKit
import SnapKit
import FSCalendar

final class CustomCalendarCell: FSCalendarCell {

    // MARK: - UI Components
    private let indicatorView = UIView()
    
    
    // MARK: - LifeCycle
    override init!(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTitleLabel()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setupViews()
    }

    // MARK: - UI Setup
    private func setupViews() {
        contentView.addSubview(indicatorView)
        
        indicatorView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.center.equalTo(titleLabel)
        }
        
        indicatorView.layer.cornerRadius = 20
    }
    
    private func setupTitleLabel() {
        titleLabel.layer.zPosition = 1
    }
}

// MARK: - update UI
extension CustomCalendarCell {
    func updateCell(isSelected: Bool,
                    isToday: Bool) {
        changeBackColor(isSelected, isToday)
    }

    private func changeBackColor(_ isSelected: Bool,
                                 _ isToday: Bool) {
        if isSelected {
            setSelectedBackColor()
        } else {
            setDefaultBackColor(isToday)
        }
    }
    
    private func setSelectedBackColor() {
        
        self.indicatorView.transform = self.indicatorView.transform.scaledBy(x: 0.001, y: 0.001)
        
        UIView.bounceAnimate {
            self.indicatorView.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            self.indicatorView.backgroundColor = .appPrimary.withAlphaComponent(0.1)
        }
    }

    private func setDefaultBackColor(_ isToday: Bool) {
        indicatorView.backgroundColor = isToday ? .bgPrimary : .clear
    }
}
 
