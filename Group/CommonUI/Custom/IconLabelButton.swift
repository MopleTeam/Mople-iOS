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
        
    public var text: String? {
        return headerLabel?.text
    }
    
    private var headerLabel: IconLabelView?
    
    init(configure: UIConstructive,
         iconSize: CGFloat = 24,
         iconAligment: IconAlignment = .right,
         labelAligment: LabelViewAligment = .center) {
        
        super.init(frame: .zero)
        self.setLabel(configure: configure,
                              iconSize: iconSize,
                              iconAligment: iconAligment)
        setupUI(aligment: labelAligment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(aligment: LabelViewAligment) {
        guard let label = headerLabel else { return }
        self.addSubview(label)
        
        switch aligment {
        case .center:
            self.setCenterAligment()
        case .fill:
            self.setFillAligment()
        }
    }
    
    private func setCenterAligment() {
        headerLabel?.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setFillAligment() {
        headerLabel?.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setLabel(configure: UIConstructive, iconSize: CGFloat, iconAligment: IconAlignment) {
        headerLabel = IconLabelView(iconSize: iconSize,
                                    configure: configure,
                                    iconAligment: iconAligment)
        
        headerLabel?.isUserInteractionEnabled = false
    }
    
    public func setText(_ text: String?) {
        self.headerLabel?.setText(text)
    }
}
