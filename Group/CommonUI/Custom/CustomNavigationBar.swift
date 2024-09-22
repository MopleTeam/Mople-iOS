//
//  CsutomNavigationBar.swift
//  Group
//
//  Created by CatSlave on 9/19/24.
//

import UIKit
import SnapKit

final class CustomNavigationBar: UIView {
    
    let titleLable: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Main.NaviView)
        label.textAlignment = .center
        return label
    }()
    
    let rightButtonContainerView = UIView()
    
    let leftButtonContainerView = UIView()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leftButtonContainerView, titleLable, rightButtonContainerView])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        leftButtonContainerView.snp.makeConstraints { make in
            make.width.equalTo(mainStackView.snp.height)
        }
        
        rightButtonContainerView.snp.makeConstraints { make in
            make.width.equalTo(mainStackView.snp.height)
        }
    }
}

// MARK: - Set Item
extension CustomNavigationBar {
    
    public func setRightItem(item: UIButton) {
        rightButtonContainerView.addSubview(item)
        
        item.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
