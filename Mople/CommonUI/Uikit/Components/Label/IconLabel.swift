//
//  InfoLabel.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import Domain
import SnapKit

final class IconLabel: UIView {
    
    // MARK: - Variables
    var text: String? {
        get { infoLabel.text }
        set { infoLabel.text = newValue}
    }
    
    let iconSize: CGSize
        
    // MARK: - UI Components
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
        let sv = UIStackView(arrangedSubviews: [imageContainerView, infoLabel])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    init(icon: UIImage?,
         iconSize: CGSize,
         frame: CGRect = .zero) {
        self.iconSize = iconSize
        super.init(frame: frame)
        setupUI()
        setupIcon(icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIcon(_ icon: UIImage?) {
        self.imageView.image = icon
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        self.imageContainerView.addSubview(imageView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.greaterThanOrEqualTo(iconSize.height)
        }
        
        imageContainerView.snp.makeConstraints { make in
            make.width.equalTo(iconSize.width)
        }

        imageView.snp.makeConstraints { make in
            make.size.equalTo(iconSize)
            make.top.centerX.equalToSuperview()
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
    
    public func setSpacing(_ spacing: CGFloat) {
        mainStackView.spacing = spacing
    }
    
    public func rightIconAligment() {
        mainStackView.reverseSubviewsZIndex()
    }
    
    public func centerIconAligment() {
        imageView.snp.remakeConstraints { make in
            make.size.equalTo(iconSize)
            make.center.equalToSuperview()
        }
    }
    
    public func setMargin(_ margin: UIEdgeInsets) {
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = margin
    }
    
    public func hideIcon(isHide: Bool) {
        imageContainerView.isHidden = isHide
    }
    
    public func addContent(with content: UIView, size: CGSize) {
        mainStackView.addArrangedSubview(content)
        
        content.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
    }
}


