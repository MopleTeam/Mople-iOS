//
//  BaseViewController.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TitleNaviViewController: UIViewController {

    // MARK: - Variables
    public var titleViewBottom: ConstraintItem {
        return navigationView.snp.bottom
    }
    
    // MARK: - Observer
    public var rightItemEvent: ControlEvent<Void> {
        return navigationView.rightItemEvent
    }
    
    public var leftItemEvent: ControlEvent<Void> {
        return navigationView.leftItemEvent
    }
        
    // MARK: - UI Components
    private var navigationView = TitleNaviBar()
    
    // MARK: - Indicator
    fileprivate let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = 1
        return indicator
    }()
    
    // MARK: - LifeCycle
    init(title: String?) {
        super.init(nibName: nil, bundle: nil)
        setTitle(title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialsetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func initialsetup() {
        setupUI()
        setNavigation()
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        self.view.addSubview(navigationView)
        self.view.addSubview(indicator)

        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }
                
        indicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setNavigation() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    private func setTitle(_ title: String?) {
        self.navigationView.setTitle(title)
    }
}

// MARK: - 네비게이션 아이템 설정
extension TitleNaviViewController {
    public func setBarItem(type: TitleNaviBar.ButtonType, image: UIImage) {
        navigationView.setBarItem(type: type, image: image)
    }
    
    public func hideBaritem(type: TitleNaviBar.ButtonType, isHidden: Bool) {
        navigationView.hideBarItem(type: type, isHidden: isHidden)
    }
}

extension Reactive where Base: TitleNaviViewController {
    var isLoading: Binder<Bool> {
        return Binder(self.base) { vc, isLoading in
            vc.indicator.rx.isAnimating.onNext(isLoading)
            vc.view.isUserInteractionEnabled = !isLoading
        }
    }
}

