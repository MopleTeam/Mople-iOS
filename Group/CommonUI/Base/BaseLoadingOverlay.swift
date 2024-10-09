//
//  BaseLoadingOverlay.swift
//  Group
//
//  Created by CatSlave on 10/9/24.
//

import UIKit
import SnapKit

final class BaseLoadingOverlay: UIView {
    
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .black.withAlphaComponent(0.3)
        self.addSubview(indicator)
        self.layer.zPosition = 2
        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    public func animatedIndicator(_ isLoading: Bool) {
        isLoading ? indicator.startAnimating() : indicator.stopAnimating()
        isHidden = !isLoading
    }
    
}
