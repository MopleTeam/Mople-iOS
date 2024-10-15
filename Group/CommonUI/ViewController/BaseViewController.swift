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

class BaseViewController: UIViewController {
    // MARK: - Variables
    public var titleViewBottom: ConstraintItem {
        return navigationView.snp.bottom
    }
    
    // MARK: - Observer
    private var rightItemEvent: Observable<Void> {
        return rightButton.rx.controlEvent(.touchUpInside)
            .asObservable()
    }
    
    private var leftItemEvent: Observable<Void> {
        return leftButton.rx.controlEvent(.touchUpInside)
            .asObservable()
    }
    
    // MARK: - UI Components
    private let navigationView: CustomNavigationBar = {
        let navi = CustomNavigationBar()
        return navi
    }()
    
    private let rightButton = UIButton()
    private let leftButton = UIButton()
    
    private let indicator = BaseLoadingOverlay()
    
    // MARK: - LifeCycle
    init(title: String?) {
        super.init(nibName: nil, bundle: nil)
        setTitle(title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = AppDesign.defaultWihte
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
    
    private func setTitle(_ title: String?) {
        self.navigationView.titleLable.text = title
    }
}

// MARK: - 네비게이션 아이템 설정
extension BaseViewController {
    public func addRightButton(setImage: UIImage?) -> Observable<Void> {
        navigationView.rightButtonContainerView.addSubview(rightButton)
        
        rightButton.setImage(setImage, for: .normal)
        
        rightButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return rightItemEvent
    }
    
    public func addLeftButton(setImage: UIImage?) -> Observable<Void> {
        navigationView.leftButtonContainerView.addSubview(leftButton)
        
        leftButton.setImage(setImage, for: .normal)
        
        leftButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return leftItemEvent
    }
    
    public func hideRightButton(isHidden: Bool) {
        rightButton.isHidden = isHidden
    }
    
    public func hideLeftButton(isHidden: Bool) {
        leftButton.isHidden = isHidden
    }
}

// MARK: - Indicator 설정
extension BaseViewController {
    public func animationIndicator(_ isLoading: Bool) {
        print(#function, #line, "isLoading : \(isLoading)" )
        indicator.animating(isLoading)
    }
}
