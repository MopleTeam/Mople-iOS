//
//  DefaultPickerView.swift
//  Mople
//
//  Created by CatSlave on 11/21/24.
//

import UIKit
import RxSwift
import RxCocoa

class DefaultPickerView: UIView {

    // MARK: - Observer
    public var closeButtonTap: ControlEvent<Void> {
        return closeButton.rx.controlEvent(.touchUpInside)
    }
    
    public var completedButtonTap: ControlEvent<Void> {
        return completeButton.rx.controlEvent(.touchUpInside)
    }
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title2.semiBold
        label.textColor = ColorStyle.Gray._02
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.close, for: .normal)
        return btn
    }()
    
    private let pickerView = UIPickerView()
    
    private let completeButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.DatePicker.completedTitle,
                     font: FontStyle.Title3.semiBold,
                     color: ColorStyle.Default.white)
        btn.setBgColor(ColorStyle.App.primary, disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(8)
        return btn
    }()
            
    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStackView, pickerView, completeButton])
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .fill
        sv.layer.cornerRadius = 13
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return sv
    }()
    
    // MARK: - LifeCycle
    init(title: String?) {
        super.init(frame: .zero)
        setTitle(title)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
    }
    
    private func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    private func setLayout() {
        self.backgroundColor = ColorStyle.Default.white
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
        }
        
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        
        completeButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    public func selectRow(row: Int, inComponent: Int, animated: Bool) {
        guard pickerView.numberOfComponents - 1 >= inComponent,
              pickerView.numberOfRows(inComponent: inComponent) - 1 >= row else { return }
        
        pickerView.selectRow(row, inComponent: inComponent, animated: animated)
    }
 
}

// MARK: - Delegate
extension DefaultPickerView {
    public func setDelegate(delegate: UIPickerViewDataSource & UIPickerViewDelegate ) {
        pickerView.delegate = delegate
    }
}

// MARK: - Dequeue Reusable
extension DefaultPickerView {
    public func dequeuePickerLabel(reusing view: UIView?) -> UILabel {
        return (view as? UILabel) ?? {
            let newLabel = UILabel()
            newLabel.textAlignment = .center
            newLabel.textColor = .black
            newLabel.font = FontStyle.Title2.semiBold
            return newLabel
        }()
    }
}
