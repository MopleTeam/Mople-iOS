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
    
    public var rightButtonObservable: Observable<Void> {
        return rightButton.rx.controlEvent(.touchUpInside)
            .asObservable()
    }
    
    public var leftButtonObservable: Observable<Void> {
        return leftButton.rx.controlEvent(.touchUpInside)
            .asObservable()
    }
    
    public var titleViewBottom: ConstraintItem {
        return navigationView.snp.bottom
    }
    
    private let navigationView: CustomNavigationBar = {
        let navi = CustomNavigationBar()
        return navi
    }()
    
    private let rightButton = UIButton()
    private let leftButton = UIButton()
    
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
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(navigationView)
        
        navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
    }
    
    private func setTitle(_ title: String?) {
        self.navigationView.titleLable.text = title
    }
}

extension BaseViewController {
    public func addRightButton(setImage: UIImage?) {
        navigationView.rightButtonContainerView.addSubview(rightButton)
        
        rightButton.setImage(setImage, for: .normal)
        
        rightButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func addLeftButton(setImage: UIImage?) {
        navigationView.leftButtonContainerView.addSubview(leftButton)
        
        leftButton.setImage(setImage, for: .normal)
        
        leftButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func hideRightButton(isHidden: Bool) {
        rightButton.isHidden = isHidden
    }
    
    public func hideLeftButton(isHidden: Bool) {
        leftButton.isHidden = isHidden
    }
}
