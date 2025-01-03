//
//  SheetTableView.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DefaultSheetView: UIView {
    
    // MARK: - UI Components
    private let contentView: UIView
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title2.semiBold
        label.textColor = ColorStyle.Gray._02
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()
    
    fileprivate let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.blackClose, for: .normal)
        return btn
    }()
    
    fileprivate lazy var completeButton: BaseButton = {
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
        let sv = UIStackView(arrangedSubviews: [headerStackView, contentView])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.layer.makeCornes(radius: 13, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        sv.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        sv.isLayoutMarginsRelativeArrangement = true
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
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    public func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    public func setCompletedBUtton() {
        self.mainStackView.addArrangedSubview(completeButton)
        self.mainStackView.spacing = 20
        
        completeButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}

extension Reactive where Base: DefaultSheetView {
    var closeEvent: ControlEvent<Void> {
        base.closeButton.rx.controlEvent(.touchUpInside)
    }
    
    var completedEvent: ControlEvent<Void> {
        base.completeButton.rx.controlEvent(.touchUpInside)
    }
}
