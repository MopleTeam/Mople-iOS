//
//  DefaultViewController.swift
//  Mople
//
//  Created by CatSlave on 12/26/24.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import SnapKit

class DefaultViewController: BaseViewController {
    
    // MARK: - Indicator
    private(set) var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = 10
        return indicator
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialsetup()
    }
    
    // MARK: - UI Setup
    private func initialsetup() {
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .bgPrimary
        self.view.addSubview(indicator)
        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension Reactive where Base: DefaultViewController {
    var isLoading: Binder<Bool> {
        return Binder(self.base) { vc, isLoading in
            vc.indicator.rx.isAnimating.onNext(isLoading)
            vc.view.isUserInteractionEnabled = !isLoading
        }
    }
}


