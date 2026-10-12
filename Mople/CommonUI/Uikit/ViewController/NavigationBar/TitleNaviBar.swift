//
//  CsutomNavigationBar.swift
//  Group
//
//  Created by CatSlave on 9/19/24.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import SnapKit

// 공통 네비게이션 바.
// 레이아웃 구조:
//   [leftStack] ── [centerContainer] ── [rightStack]
//   - leftStack  : 좌측 아이템들(뒤로가기 등). leading 20, 비어있으면 폭 0
//   - rightStack : 우측 아이템들(리스트/확성기 등). trailing 20, 비어있으면 폭 0
//   - centerContainer : 화면 중앙(centerX) 고정 + 좌우 스택과 부등식 제약
//       → 타이틀이 짧으면 정중앙, 길면 가까운 쪽 버튼에 닿기 전에 대칭으로 잘림(겹침 방지)
// 좌우 아이템 개수가 비대칭이어도 타이틀은 항상 화면 중앙을 유지한다.
final class TitleNaviBar: UIView {

    enum ButtonType {
        case left
        case right
    }

    // MARK: - Observable
    // 기존 단일 우측/좌측 버튼(setBarItem으로 설정) 이벤트 — 하위 호환 유지
    public var rightItemEvent: ControlEvent<Void> {
        return rightButton.rx.controlEvent(.touchUpInside)
    }

    public var leftItemEvent: ControlEvent<Void> {
        return leftButton.rx.controlEvent(.touchUpInside)
    }

    // MARK: - UI Components
    private let titleLable: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title2.bold
        label.textColor = .text01
        label.textAlignment = .center
        return label
    }()

    // 기본 단일 버튼 (setBarItem으로 노출). 스택에 미리 추가되며 숨겨진 상태로 시작.
    fileprivate lazy var rightButton: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()

    fileprivate lazy var leftButton: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()

    // 좌/우 아이템 컨테이너 — 여러 버튼을 담을 수 있는 스택
    private let leftStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 8
        return sv
    }()

    private let rightStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 8
        return sv
    }()

    // 중앙 타이틀 영역 (titleLable 또는 커스텀 뷰를 담음)
    private let centerContainer = UIView()

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
        addSubview(leftStack)
        addSubview(rightStack)
        addSubview(centerContainer)

        // 기본 단일 버튼을 각 스택에 미리 추가 (숨김 → setBarItem 시 노출)
        leftStack.addArrangedSubview(leftButton)
        rightStack.addArrangedSubview(rightButton)
        setItemSize(leftButton)
        setItemSize(rightButton)

        // 기본 타이틀 라벨을 중앙 컨테이너에 채움
        centerContainer.addSubview(titleLable)
        titleLable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        leftStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        rightStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        // 중앙 고정 + 좌우 스택과 겹치지 않도록 부등식 제약 → 항상 화면 중앙 유지
        centerContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(leftStack.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(rightStack.snp.leading).offset(-8)
        }
    }

    // 네비 아이템 기본 사이즈(40) 지정
    private func setItemSize(_ view: UIView) {
        view.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }
}

// MARK: - Configure
extension TitleNaviBar {

    public func setTitle(_ title: String?) {
        titleLable.text = title
    }

    public func setTitleColor(_ color: UIColor) {
        titleLable.textColor = color
    }

    public func setBarItem(type: ButtonType, image: UIImage) {
        switch type {
        case .left:
            leftButton.isHidden = false
            leftButton.setImage(image, for: .normal)
        case .right:
            rightButton.isHidden = false
            rightButton.setImage(image, for: .normal)
        }
    }

    public func hideBarItem(type: ButtonType, isHidden: Bool) {
        switch type {
        case .left:
            leftButton.isHidden = isHidden
        case .right:
            rightButton.isHidden = isHidden
        }
    }

    // MARK: - 다중 아이템 / 커스텀 타이틀 (신규 API)

    /// 우측에 아이템을 추가한다. 기존 우측 아이템들의 "안쪽(왼쪽)"에 삽입된다.
    /// 예) rightButton(리스트)이 있는 상태에서 확성기를 추가하면 [확성기][리스트] 순으로 배치.
    /// 배지/툴팁/탭 이벤트는 호출부가 전달한 버튼에 직접 붙여 사용한다.
    @discardableResult
    public func addRightItem(_ button: UIButton, size: CGFloat = 40) -> UIButton {
        rightStack.insertArrangedSubview(button, at: 0)
        button.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        return button
    }

    /// 좌측에 아이템을 추가한다. 기존 좌측 아이템들의 "안쪽(오른쪽)"에 추가된다.
    @discardableResult
    public func addLeftItem(_ button: UIButton, size: CGFloat = 40) -> UIButton {
        leftStack.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        return button
    }

    /// 기본 titleLable 대신 커스텀 뷰를 중앙에 배치한다(화면 중앙 유지 + 겹침 방지 제약 그대로 적용).
    /// 커스텀 뷰 내부 라벨은 compressionResistance가 1000 미만이어야 자동 truncate 된다.
    public func setCustomTitleView(_ view: UIView) {
        titleLable.removeFromSuperview()
        centerContainer.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension Reactive where Base: TitleNaviBar {
    var leftItemTap: ControlEvent<Void> {
        return base.leftButton.rx.controlEvent(.touchUpInside)
    }

    var rightItemTap: ControlEvent<Void> {
        return base.rightButton.rx.controlEvent(.touchUpInside)
    }
}
