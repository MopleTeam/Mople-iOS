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
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLable])
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
            make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
    }
}
