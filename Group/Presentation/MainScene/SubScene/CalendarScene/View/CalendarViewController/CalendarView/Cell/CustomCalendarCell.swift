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
    
    private var isCornerRadiusSet = false
    
    private let dotContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private let eventDot: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    private let indicatorView = UIView()
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTitleLabel()
    }
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !isCornerRadiusSet {
            indicatorView.layer.cornerRadius = indicatorView.frame.height / 2
            dotContainer.layer.cornerRadius = dotContainer.frame.height / 2
            eventDot.layer.cornerRadius = eventDot.frame.height / 2
            isCornerRadiusSet = true
        }
    }
    
    private func setupViews() {
        contentView.addSubview(indicatorView)
        indicatorView.addSubview(dotContainer)
        dotContainer.addSubview(eventDot)
        
        indicatorView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.center.equalTo(titleLabel)
        }
        
        dotContainer.snp.makeConstraints { make in
            make.size.equalTo(12)
            make.bottom.trailing.equalToSuperview()
        }
        
        eventDot.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        
    }
    
    private func setupTitleLabel() {
        titleLabel.layer.zPosition = 1
    }
}

// MARK: - update UI
extension CustomCalendarCell {
    func updateCell(containsEvent: Bool,
                    isSelected: Bool,
                    isToday: Bool) {
        clearBackColor(isToday)
        changeBackColor(containsEvent, isSelected, isToday)
    }
    
    private func clearBackColor(_ isToday: Bool) {
        if isToday {
            indicatorView.backgroundColor = .clear
        }
    }
    
    private func changeBackColor(_ containsEvent: Bool,
                                 _ isSelected: Bool,
                                 _ isToday: Bool) {
        if isSelected {
            showViewAnimated(containsEvent, isToday)
        } else {
            showView(containsEvent, isToday)
        }
    }
    
    private func showViewAnimated(_ containsEvent: Bool,
                                  _ isToday: Bool) {
        
        self.indicatorView.transform = self.indicatorView.transform.scaledBy(x: 0.001, y: 0.001)
        
        UIView.bounceAnimate {
            self.indicatorView.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            self.setBackGroundColor(isToday, true)
            self.dotContainer.isHidden = !containsEvent
        }
    }
    
    private func showView(_ containsEvent: Bool,
                          _ isToday: Bool) {
        
        self.setBackGroundColor(isToday, false)
        self.dotContainer.isHidden = !containsEvent
        
    }
    
    private func setEvent(_ containsEvent: Bool) {
        dotContainer.isHidden = !containsEvent
    }
    
    private func setBackGroundColor(_ isToday: Bool, _ isSelected: Bool) {
        if isSelected {
            indicatorView.backgroundColor = .init(hexCode: "3366FF").withAlphaComponent(0.1)
        } else {
            indicatorView.backgroundColor = isToday ? .init(hexCode: "F4F5F6") : .clear
        }
    }
}
 
