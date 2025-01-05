//
//  DefaultViewController.swift
//  Mople
//
//  Created by CatSlave on 12/26/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class DefaultViewController: UIViewController {

    // MARK: - Indicator
    fileprivate let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = 1
        return indicator
    }()
    
    // MARK: - LifeCycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialsetup()
    }

    // MARK: - UI Setup
    private func initialsetup() {
        setupUI()
        setNavigation()
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        self.view.addSubview(indicator)
     
        indicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setNavigation() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
}

extension Reactive where Base: DefaultViewController {
    var isLoading: Binder<Bool> {
        return Binder(self.base) { vc, isLoading in
            print(#function, #line, "#3 : \(isLoading)" )
            vc.indicator.rx.isAnimating.onNext(isLoading)
            vc.view.isUserInteractionEnabled = !isLoading
        }
    }
}


