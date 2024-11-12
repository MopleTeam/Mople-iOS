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

final class IconLabelButton: UIView {
    
    private var iconLabel: UILabel = UILabel()
    
    init(icon: UIImage?,
         iconSize: CGFloat) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        iconLabel.backgroundColor = .systemYellow
        self.addSubview(iconLabel)
        iconLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension IconLabelButton {
    public func setText(text: String?) {
        iconLabel.text = text
    }
}
//
//    private var headerLabel: IconLabel?
//    
//    init(configure: UIConstructive,
//         iconSize: CGFloat = 24,
//         iconAligment: IconAlignment = .right,
//         contentSpacing: CGFloat = 0,
//         labelAligment: LabelViewAligment = .center) {
//        
//        super.init(frame: .zero)
//        self.setLabel(configure: configure,
//                      iconSize: iconSize,
//                      iconAligment: iconAligment,
//                      contentSpacing: contentSpacing)
//        setupUI(aligment: labelAligment)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI(aligment: LabelViewAligment) {
//        guard let label = headerLabel else { return }
//        self.addSubview(label)
//        setAligment(aligment)
//    }
//    
//    
//    
//    private func setLabel(configure: UIConstructive,
//                          iconSize: CGFloat,
//                          iconAligment: IconAlignment,
//                          contentSpacing: CGFloat) {
//        headerLabel = IconLabel(iconSize: iconSize,
//                                    configure: configure,
//                                    contentSpacing: contentSpacing,
//                                    iconAligment: iconAligment)
//        
//        headerLabel?.isUserInteractionEnabled = false
//    }
//}
//
//extension IconLabelButton {
//    private func setAligment(_ aligment: LabelViewAligment) {
//        switch aligment {
//        case .center:
//            self.setCenterAligment()
//        case .fill:
//            self.setFillAligment()
//        }
//    }
//    
//    private func setCenterAligment() {
//        headerLabel?.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
//    }
//    
//    private func setFillAligment() {
//        headerLabel?.snp.makeConstraints { make in
//            make.horizontalEdges.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
//    }
//}
//
//extension IconLabelButton {
//    public var text: String? {
//        get {
//            headerLabel?.text
//        } set {
//            headerLabel?.text = newValue
//        }
//    }
//    
//    public func setBackColor(_ color: UIColor?) {
//        backgroundColor = color
//    }
//    
//    public func setRadius(_ radius: CGFloat) {
//        clipsToBounds = false
//        layer.cornerRadius = radius
//    }
//}
