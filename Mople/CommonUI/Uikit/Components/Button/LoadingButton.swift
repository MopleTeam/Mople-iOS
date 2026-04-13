//
//  LoadingButton.swift
//  Mople
//
//  Created by CatSlave on 7/24/25.
//

import UIKit
import Domain
import RxSwift
import RxCocoa

final class LoadingButtonView: UIView {
    
    public let button: BaseButton = {
        let btn = BaseButton()
        btn.layer.zPosition = 1
        return btn
    }()
    
    fileprivate let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(button)
        self.addSubview(indicator)
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    public func stopLoading() {
        button.isHidden = false
        indicator.stopAnimating()
    }
    
    public func startLoading() {
        button.isHidden = true
        indicator.startAnimating()
    }
}

extension Reactive where Base: LoadingButtonView {
    var tap: ControlEvent<Void> {
        return base.button.rx.tap
    }
}
