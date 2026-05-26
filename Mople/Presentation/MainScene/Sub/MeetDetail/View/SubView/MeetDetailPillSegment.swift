//
//  MeetDetailPillSegment.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

// 예정된 약속 / 지난 약속 알약(pill) 세그먼트.
// 전체 폭 200, 높이 48, 반지름 22의 둥근 알약 + 좌우 6 padding.
// 선택 시 appPrimary 배경 + 흰 글자 + 미세 그림자.
final class MeetDetailPillSegment: UIView {

    // MARK: - Public
    private(set) var selectedIndex: Int = 0
    var selectedIndexChanged: Observable<Int> { selectedSubject.asObservable() }

    // MARK: - Private
    private let selectedSubject = PublishSubject<Int>()
    private let disposeBag = DisposeBag()
    private let titles: [String]
    private var buttons: [UIButton] = []

    // 선택된 알약 — 버튼 frame에 맞춰 슬라이드.
    // button height = container(48) - padding(6+6) = 36 → cornerRadius 18 (capsule)
    private let selectedPill: UIView = {
        let v = UIView()
        v.backgroundColor = .appPrimary
        v.layer.cornerRadius = 18
        v.layer.makeShadow(opactity: 0.12, radius: 8, offset: .init(width: 0, height: 0))
        return v
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.spacing = 8
        return sv
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.bgPrimary.withAlphaComponent(0.6)
        v.layer.cornerRadius = 24
        return v
    }()

    init(titles: [String], defaultIndex: Int = 0) {
        self.titles = titles
        self.selectedIndex = defaultIndex
        super.init(frame: .zero)
        makeButtons()
        setupUI()
        bind()
        DispatchQueue.main.async { [weak self] in
            self?.updatePillPosition(animated: false)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeButtons() {
        buttons = titles.enumerated().map { index, title in
            let btn = UIButton()
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = FontStyle.Body1.semiBold
            btn.setTitleColor(.text03, for: .normal)
            btn.setTitleColor(.primaryText, for: .selected)
            btn.tag = index
            btn.isSelected = (index == selectedIndex)
            return btn
        }
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(selectedPill)
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
    }

    private func bind() {
        for button in buttons {
            button.rx.controlEvent(.touchUpInside)
                .map { button.tag }
                .subscribe(with: self, onNext: { owner, idx in
                    owner.select(index: idx)
                })
                .disposed(by: disposeBag)
        }
    }

    private func select(index: Int) {
        guard index != selectedIndex else { return }
        selectedIndex = index
        buttons.enumerated().forEach { $0.element.isSelected = ($0.offset == index) }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) { [weak self] in
            self?.updatePillPosition(animated: true)
            self?.layoutIfNeeded()
        }
        selectedSubject.onNext(index)
    }

    private func updatePillPosition(animated: Bool) {
        guard let target = buttons[safe: selectedIndex] else { return }
        selectedPill.snp.remakeConstraints { make in
            make.edges.equalTo(target)
        }
    }
}
