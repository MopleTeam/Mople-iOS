//
//  BaseViewController.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    var titleViewBottom: ConstraintItem {
        return navigationView.snp.bottom
    }
    
    private let navigationView: CustomNavigationBar = {
        let navi = CustomNavigationBar()
        return navi
    }()
    
    let rightButton = UIButton()
    let leftButton = UIButton()
    
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
    func addRightButton(setImage: UIImage) {
        navigationView.rightButtonContainerView.addSubview(rightButton)
        
        rightButton.setImage(setImage, for: .normal)
        
        rightButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addLeftButton() {
        navigationView.leftButtonContainerView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
