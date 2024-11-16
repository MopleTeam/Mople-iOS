//
//  CsutomNavigationBar.swift
//  Group
//
//  Created by CatSlave on 9/19/24.
//

import UIKit
import SnapKit

final class DefaultNavigationBar: UIView {
    
    let titleLable: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title2.bold
        label.textColor = ColorStyle.Gray._01
        label.textAlignment = .center
        return label
    }()
    
    let rightButtonContainerView = UIView()
    
    let leftButtonContainerView = UIView()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leftButtonContainerView, titleLable, rightButtonContainerView])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
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
            make.horizontalEdges.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview()
        }
                
        leftButtonContainerView.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        rightButtonContainerView.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
    }
}

// MARK: - Set Item
extension DefaultNavigationBar {
    
    public func setRightItem(item: UIButton) {
        rightButtonContainerView.addSubview(item)
        
        item.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
