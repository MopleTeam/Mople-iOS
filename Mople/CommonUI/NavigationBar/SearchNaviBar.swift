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
    
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private(set) lazy var searchTextField: DefaultTextField = {
        let textField = DefaultTextField()
        textField.setPlaceholder("장소를 검색해주세요")
        textField.setInputTextField(view: searchButton, mode: .right)
        textField.inputTextField.returnKeyType = .search
        return textField
    }()
    
    fileprivate let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.backArrow, for: .normal)
        return btn
    }()
    
    fileprivate let searchButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: "검색",
                     font: FontStyle.Body2.semiBold,
                     normalColor: ColorStyle.Default.white)
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(4)
        btn.isEnabled = false
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
        bind()
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
    
    // MARK: - Bind
    private func bind() {
        searchTextField.rx.editText
            .map({ $0?.count ?? 0 >= 1 })
            .bind(to: searchButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: SearchNaviBar {
    
    var editEvent: ControlEvent<Void> {
        base.searchTextField.rx.editEvent
    }
    
    var searchButtonEvent: Observable<String> {
        base.searchButton.rx.controlEvent(.touchUpInside)
            .compactMap { _ in
                base.searchTextField.text
            }
    }
    
    var searchEvent: Observable<String> {
        base.searchTextField.rx.returnEvent
            .compactMap { _ in
                base.searchTextField.text
            }
            .filter { $0.count >= 1 }
    }
    
    var backEvent: ControlEvent<Void> {
        base.backButton.rx.controlEvent(.touchUpInside)
    }
    
    var isEditMode: Observable<Bool> {
        return base.searchTextField.rx.isEditMode
    }
}
