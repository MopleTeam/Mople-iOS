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

final class IconLabelView: UIView {
    
    private var configure: UIConstructive
    private var iconSize: CGFloat
    
    private let imageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let labelContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = configure.itemConfig.image
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var infoLabel: BaseLabel = {
        let label = BaseLabel(configure: configure)
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
    
    init(iconSize: CGFloat,
         configure: UIConstructive,
         contentSpacing: CGFloat = 0,
         iconAligment: IconAlignment = .left) {
        self.configure = configure
        self.iconSize = iconSize
        
        defer {
            setupUI()
            mainStackView.spacing = contentSpacing
            setIconAligment(iconAligment)
        }
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        self.imageContainerView.addSubview(imageView)
        self.labelContainerView.addSubview(infoLabel)
        self.clipsToBounds = true
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainerView.snp.makeConstraints { make in
            make.width.equalTo(iconSize)
        }

        imageView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.size.equalTo(iconSize)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview().inset(2)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    private func setIconAligment(_ iconAligment: IconAlignment) {
        if iconAligment == .right {
            mainStackView.reverseSubviewsZIndex()
        }
    }
    
    public func setText(_ text: String?) {
        self.infoLabel.text = text
    }
    
    public func setMargin(_ margin: UIEdgeInsets) {
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = margin
    }
}

extension UIStackView {

    func reverseSubviewsZIndex(setNeedsLayout: Bool = true) {
        let stackedViews = self.arrangedSubviews

        stackedViews.forEach {
            self.removeArrangedSubview($0)
        }
        
        stackedViews.reversed().forEach(addArrangedSubview(_:))
    }
}
