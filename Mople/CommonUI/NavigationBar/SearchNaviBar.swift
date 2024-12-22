//
//  DefaultSearchBar.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SearchNaviBar: UIView {
 
    enum ButtonType {
        case left
        case right
    }
    
    // MARK: - Observable
    public var searchButtonEvent: ControlEvent<Void> {
        return searchButton.rx.controlEvent(.touchUpInside)
    }
    
    public var backButtonEvent: ControlEvent<Void> {
        return backButton.rx.controlEvent(.touchUpInside)
    }
    
    // MARK: - UI Components
    private lazy var searchTextField: DefaultTextField = {
        let textField = DefaultTextField()
        textField.setPlaceholder("장소를 검색해주세요")
        textField.setInputTextField(view: searchButton, mode: .right)
        return textField
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.arrowBack, for: .normal)
        return btn
    }()
    
    private let searchButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: "검색",
                     font: FontStyle.Body2.semiBold,
                     color: ColorStyle.Default.white)
        btn.setBgColor(ColorStyle.App.primary)
        btn.setRadius(4)
        return btn
    }()

    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [backButton, searchTextField])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview()
        }
        
        searchTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        backButton.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
    }
}




