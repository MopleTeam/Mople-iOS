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
        return mainStackView.snp.bottom
    }
    
    private let titleLable: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Main.NaviView)
        label.textAlignment = .center
        return label
    }()
    
    private let rightButtonContainerView = UIView()
    private let leftButtonContainerView = UIView()
    
    let leftButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    let rightButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leftButtonContainerView, titleLable, rightButtonContainerView])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    init(title: String?) {
        super.init(nibName: nil, bundle: nil)
        self.titleLable.setText(text: title)
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
        self.view.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
                
        leftButtonContainerView.snp.makeConstraints { make in
            make.width.equalTo(mainStackView.snp.height)
        }
        
        rightButtonContainerView.snp.makeConstraints { make in
            make.width.equalTo(mainStackView.snp.height)
        }
    }
}

extension BaseViewController {
    func addRightButton(setImage: UIImage) {
        rightButtonContainerView.addSubview(rightButton)
        
        rightButton.setImage(setImage, for: .normal)
        
        rightButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addLeftButton() {
        leftButtonContainerView.addSubview(leftButton)
        
        leftButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
