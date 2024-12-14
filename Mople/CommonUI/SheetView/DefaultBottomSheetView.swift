//
//  BottomSheetView.swift
//  Mople
//
//  Created by CatSlave on 12/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DefaultBottomSheetView: UIView {
    // MARK: - Observer
    public var closeButtonTap: ControlEvent<Void> {
        return closeButton.rx.controlEvent(.touchUpInside)
    }
    
    public var completedButtonTap: ControlEvent<Void> {
        return completeButton.rx.controlEvent(.touchUpInside)
    }
    
    // MARK: - UI Components
    private let contentView: UIView
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title2.semiBold
        label.textColor = ColorStyle.Gray._02
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.close, for: .normal)
        return btn
    }()
    
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
        let sv = UIStackView(arrangedSubviews: [headerStackView, contentView, completeButton])
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .fill
        sv.layer.cornerRadius = 13
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return sv
    }()
    
    init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    public func setTitle(_ title: String?) {
        titleLabel.text = title
    }
}
