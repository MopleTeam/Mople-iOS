//
//  BaseViewController.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TitleNaviViewController: DefaultViewController {
    
    // MARK: - Variables
    private let initiallyNavigationBar: Bool
        
    public var titleViewBottom: ConstraintItem {
        if self.view.subviews.contains(naviBar) {
            return naviBar.snp.bottom
        } else {
            return notchView.snp.bottom
        }
    }
    
    fileprivate var superTapViewHeight: CGFloat {
        return notchView.frame.height
    }
    
    fileprivate var naviBarViewHeight: CGFloat {
        return naviBar.frame.height
    }
    
    // MARK: - UI Components
    public let notchView: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultWhite
        view.layer.zPosition = 2
        return view
    }()
    
    public var naviBar: TitleNaviBar = {
        let navi = TitleNaviBar()
        navi.backgroundColor = .defaultWhite
        navi.layer.zPosition = 1
        return navi
    }()

    // MARK: - LifeCycle
    init(screenName: ScreenName? = nil,
         initiallyNavigationBar: Bool = true,
         title: String?) {
        self.initiallyNavigationBar = initiallyNavigationBar
        super.init(screenName: screenName)
        setTitle(title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayer()
        setNavigation()
    }
    
    private func setLayer() {
        self.view.backgroundColor = .defaultWhite
        self.view.addSubview(notchView)        
        notchView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(UIScreen.getTopNotchSize())
        }
        
        if initiallyNavigationBar {
            addNaviBar()
        }
    }
    
    public func addNaviBar() {
        self.view.addSubview(naviBar)

        naviBar.snp.makeConstraints { make in
            make.top.equalTo(notchView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }
    }
    
    private func setNavigation() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    private func setTitle(_ title: String?) {
        self.naviBar.setTitle(title)
    }
}

// MARK: - Set NaviBar
extension TitleNaviViewController {
    public func moveTopOutOfView() {
        let adjustOffset = -(superTapViewHeight + naviBarViewHeight)
        setTopOffset(adjustOffset)
    }
    
    public func moveTopIntoView() {
        setTopOffset(0)
    }
    
    public func hideTop(isHide: Bool) {
        notchView.isHidden = isHide
        naviBar.isHidden = isHide
    }
    
    private func setTopOffset(_ offset: CGFloat) {
        notchView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(offset)
        }
    }
}

// MARK: - 네비게이션 아이템 설정
extension TitleNaviViewController {
    public func setBarItem(type: TitleNaviBar.ButtonType, image: UIImage = .backArrow) {
        naviBar.setBarItem(type: type, image: image)
    }
    
    public func hideBaritem(type: TitleNaviBar.ButtonType, isHidden: Bool) {
        naviBar.hideBarItem(type: type, isHidden: isHidden)
    }
}
