//
//  CustomSegment.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import RxSwift

final class DefaultSegmentedControl: UIView {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    private var selectedIndex: Int
    
    // MARK: - Observables
    private let selectedButton: PublishSubject<Int> = .init()
    
    // MARK: - UI Components
    fileprivate var buttons: [BaseButton] = []
    
    private let selectedView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .appPrimary
        view.layer.zPosition = 1
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = .bgPrimary
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return stackView
    }()
    
    init(buttonTitles: [String],
         defaultIndex: Int = 0) {
        self.selectedIndex = defaultIndex
        super.init(frame: .zero)
        makeButtons(titles: buttonTitles,
                    defaultIndex: defaultIndex)
        setupUI()
        setButtonAction()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setLayout()
        setSelectedView()
    }
    
    private func setLayout() {
        self.addSubview(mainStackView)
        self.mainStackView.addSubview(selectedView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func makeButtons(titles: [String], defaultIndex: Int) {
        buttons = titles.enumerated().map({ index, title in
            let button = BaseButton()
            button.setTitle(text: title,
                            font: FontStyle.Body1.semiBold,
                            normalColor: .gray04,
                            selectedColor: .defaultWhite)
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.layer.zPosition = 2
            button.tag = index
            return button
        })
    }
    
    // MARK: - Action
    private func setButtonAction() {
        let buttonEvents = buttons.map {
            let button = $0
            return button.rx.controlEvent(.touchUpInside)
                .map { button.tag }
        }
        
        Observable.merge(buttonEvents)
            .bind(to: selectedButton)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Bind
    private func bind() {
        selectedButton
            .subscribe(with: self, onNext: { vc, index in
                vc.didSelected(index: index)
            })
            .disposed(by: disposeBag)
    }
}

extension DefaultSegmentedControl {
    fileprivate func didSelected(index: Int) {
        selectedIndex = index
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            setSelectedView()
            setNonSelectedView()
            self.layoutIfNeeded()
        })
    }
    
    private func setSelectedView() {
        guard let selectedButton = mainStackView.arrangedSubviews[safe: selectedIndex]
                as? BaseButton else { return }
        selectedButton.updateSelectedTextColor(isSelected: true)
        selectedView.snp.remakeConstraints { make in
            make.edges.equalTo(selectedButton)
        }
    }
    
    private func setNonSelectedView() {
        mainStackView.arrangedSubviews.forEach { [weak self] in
            guard let button = $0 as? BaseButton,
                  button.tag != self?.selectedIndex else { return }
            button.updateSelectedTextColor(isSelected: false)
        }
    }
}

extension Reactive where Base: DefaultSegmentedControl {
    var tapped: Observable<Int> {
        let buttonEvents = base.buttons.map {
            let button = $0
            return button.rx.controlEvent(.touchUpInside)
                .map { button.tag }
        }
        return Observable.merge(buttonEvents)
    }
}
