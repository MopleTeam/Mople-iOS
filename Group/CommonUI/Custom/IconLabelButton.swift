//
//  IconLabelButton.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit
import SnapKit

enum LabelViewAligment {
    case center
    case fill
}

final class IconLabelButton: UIButton {
    
    private var iconLabel: IconLabel?
    
    init(icon: UIImage?,
         iconSize: CGFloat) {
        super.init(frame: .zero)
        iconLabel = .init(icon: icon, iconSize: iconSize)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        guard let iconLabel else { return }
        iconLabel.backgroundColor = .systemYellow
        iconLabel.isUserInteractionEnabled = false
        self.addSubview(iconLabel)
        iconLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension IconLabelButton {
    public func setText(text: String?) {
        iconLabel?.text = text
    }
}

final class TestIconLabelButton: UIButton {
        
    public var text: String? {
        return headerLabel.text
    }
    
    private var headerLabel: UILabel = .init()
    
    init(iconSize: CGFloat = 24,
         iconAligment: IconAlignment = .right,
         labelAligment: LabelViewAligment = .center) {
        
        super.init(frame: .zero)
        headerLabel.font = .systemFont(ofSize: 16)
        self.clipsToBounds = true
//        self.setLabel(configure: configure,
//                              iconSize: iconSize,
//                              iconAligment: iconAligment)
        setupUI(aligment: labelAligment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(aligment: LabelViewAligment) {
        self.addSubview(headerLabel)
        
        switch aligment {
        case .center:
            self.setCenterAligment()
        case .fill:
            self.setFillAligment()
        }
    }
    
    private func setCenterAligment() {
        headerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setFillAligment() {
        headerLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setLabel(configure: UIConstructive, iconSize: CGFloat, iconAligment: IconAlignment) {
//        headerLabel = IconLabelView(iconSize: iconSize,
//                                    configure: configure,
//                                    iconAligment: iconAligment)
//
        headerLabel.isUserInteractionEnabled = false
    }
    
    public func setText(_ text: String?) {
        self.headerLabel.text = text
    }
}
