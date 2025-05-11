//
//  EmptyView.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import SnapKit

class DefaultEmptyView: UIView {

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = .gray06
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageView, label])
        sv.axis = .vertical
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    init(imageSize: CGSize = .init(width: 80, height: 80)) {
        super.init(frame: .zero)
        setupUI(imageSize: imageSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(imageSize: CGSize) {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.lessThanOrEqualToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(imageSize.width)
            make.height.lessThanOrEqualTo(imageSize.height)
        }
    }
}

extension DefaultEmptyView {
    public func setTitle(text: String? = nil) {
        label.text = text
    }
    
    public func setImage(image: UIImage?) {
        imageView.image = image
    }
}
