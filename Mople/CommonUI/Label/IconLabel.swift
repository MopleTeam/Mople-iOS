//
//  InfoLabel.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import SnapKit

enum IconAlignment {
    case left
    case right
}

final class IconLabel: UIView {
    
    var text: String? {
        didSet {
            infoLabel.text = text
        }
    }
        
    private let imageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let labelContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, labelContainerView])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    init(icon: UIImage?,
         iconSize: CGSize) {
        super.init(frame: .zero)
        setupUI(iconSize: iconSize)
        setupIcon(icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIcon(_ icon: UIImage?) {
        self.imageView.image = icon
    }
    
    private func setupUI(iconSize: CGSize) {
        self.addSubview(mainStackView)
        self.labelContainerView.addSubview(infoLabel)
        self.imageContainerView.addSubview(imageView)
//        self.clipsToBounds = true
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainerView.snp.makeConstraints { make in
            make.width.equalTo(iconSize.width)
        }

        imageView.snp.makeConstraints { make in
            make.size.equalTo(iconSize)
            make.top.centerX.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview().inset(2)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension IconLabel {
    public func setTitle(text: String? = nil,
                         font: UIFont? = nil,
                         color: UIColor? = nil) {
        infoLabel.text = text
        infoLabel.font = font
        infoLabel.textColor = color
    }
    
    public func setTitleTopPadding(_ padding: CGFloat) {
        infoLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(padding)
        }
    }
    
    public func setSpacing(_ spacing: CGFloat) {
        mainStackView.spacing = spacing
    }
    
    public func setIconAligment(_ iconAligment: IconAlignment) {
        if iconAligment == .right {
            mainStackView.reverseSubviewsZIndex()
        }
    }
    
    public func setMargin(_ margin: UIEdgeInsets) {
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = margin
    }
    
    public func hideIcon(isHide: Bool) {
        imageContainerView.isHidden = isHide
    }
}


