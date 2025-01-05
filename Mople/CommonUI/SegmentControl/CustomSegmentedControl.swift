//
//  CustomSegment.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import RxSwift

final class CustomSegmentedControl: UIView {
        
    fileprivate let nextButton: BaseButton = {
        let button = BaseButton()
        button.setTitle(text: "예정된 약속",
                       font: FontStyle.Body1.semiBold,
                       normalColor: ColorStyle.Gray._04,
                       selectedColor: ColorStyle.Default.white)
        button.updateTextColor(isSelected: true)
        return button
    }()
    
    fileprivate let previousButton: BaseButton = {
        let button = BaseButton()
        button.setTitle(text: "지난 약속",
                       font: FontStyle.Body1.semiBold,
                       normalColor: ColorStyle.Gray._04,
                       selectedColor: ColorStyle.Default.white)
        return button
    }()
    
    private let selectedView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = ColorStyle.App.primary
        view.layer.zPosition = 1
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nextButton, previousButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = ColorStyle.BG.primary
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setLayout()
        setButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.addSubview(mainStackView)
        self.mainStackView.addSubview(selectedView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectedView.snp.makeConstraints { make in
            make.edges.equalTo(nextButton)
        }
    }
    
    private func setButton() {
        [nextButton, previousButton].forEach {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 6
            $0.layer.zPosition = 2
        }
    }
}

extension CustomSegmentedControl {
    fileprivate func updateSelectedViewPosition(isNext: Bool) {
        updateTextColor(isNext: isNext)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.selectedView.snp.remakeConstraints { make in
                make.edges.equalTo(isNext ? self.nextButton : self.previousButton)
            }
            
            self.layoutIfNeeded()
        })
    }
    
    private func updateTextColor(isNext: Bool) {
        self.nextButton.updateTextColor(isSelected: isNext)
        self.previousButton.updateTextColor(isSelected: !isNext)
    }
}

extension Reactive where Base: CustomSegmentedControl {
    var nextTap: Observable<Bool> {
        return base.nextButton.rx.controlEvent(.touchUpInside)
            .do(onNext: { [weak base] in
                base?.updateSelectedViewPosition(isNext: true)
            })
            .map({ true })
            .asObservable()
    }
    
    var previousTap: Observable<Bool> {
        return base.previousButton.rx.controlEvent(.touchUpInside)
            .do(onNext: { [weak base] in
                base?.updateSelectedViewPosition(isNext: false)
            })
            .map({ false })
            .asObservable()
    }
}
