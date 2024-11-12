//
//  EmptyView.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import SnapKit

class BaseEmptyView: UIView {

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let label = UILabel()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageView, label])
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
    }
}

extension BaseEmptyView {
    public func setTitle(text: String? = nil,
                         font: UIFont? = nil,
                         color: UIColor? = nil) {
        label.text = text
        label.font = font
        label.textColor = color
    }
    
    public func setImage(image: UIImage?) {
        imageView.image = image
    }
}
