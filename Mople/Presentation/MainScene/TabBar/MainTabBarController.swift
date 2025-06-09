//
//  CustomTabBar.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift

final class MainTabBarController: UITabBarController, View {
    
    // MARK: - Reactor
    typealias Reactor = MainTabBarReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Variables
    private var isDidRander = false
    
    // MARK: - Alert
    private let alertManager = AlertManager.shared
    
    // MARK: - Observable
    private let joinMeetSubject: PublishSubject<String> = .init()
    private let resetNotifySubject: PublishSubject<Void> = .init()
    private let reqeusetNotification: PublishSubject<Void> = .init()
    
    // MARK: - Indicator
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = 10
        return indicator
    }()
    
    // MARK: - UI Components
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.makeCornes(radius: 16, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        view.layer.makeLine(width: 1, color: .appStroke)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: - LifeCycle
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultTabBarController Deinit" )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewDidRender()
        updateTabBarFrame()
    }
    
    private func viewDidRender() {
        guard !isDidRander else { return }
        isDidRander = true
        setTabBar()
        setupUI()
        trackingTapVC()
        setReactorStateBind(reactor!)
        checkNotifyPermisstion()
    }

    // MARK: - Setup UI
    private func setupUI() {
        self.view.addSubview(indicator)
        self.tabBar.backgroundColor = .defaultWhite
        self.tabBar.addSubview(borderView)
        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        borderView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(tabBar.snp.horizontalEdges)
            make.bottom.equalTo(tabBar.snp.bottom)
            make.top.equalTo(tabBar.snp.top).offset(-1)
        }
    }
    
    private func setTabBar() {
        self.delegate = self
        tabBar.clipsToBounds = false
        tabBar.layer.makeCornes(radius: 16, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        tabBar.layer.makeShadow(opactity: 0.02,
                                radius: 12)
    }
    
    private func updateTabBarFrame() {
        guard UIScreen.hasNotch() else { return }
        let newHeight: CGFloat = tabBar.frame.height + 10
        var tabFrame = tabBar.frame
        tabFrame.size.height = newHeight
        tabBar.frame = tabFrame
    }
    
    private func setIndicatorAnimating(isStart: Bool) {
        if isStart {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
    
    private func checkNotifyPermisstion() {
        reqeusetNotification.onNext(())
    }
}

// MARK: - Reactor Setup
extension MainTabBarController {
    func bind(reactor: MainTabBarReactor) {
        inputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
        setNotificationBind(reactor)
    }

    private func setActionBind(_ reactor: Reactor) {
        joinMeetSubject
            .map { Reactor.Action.joinMeet(code: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resetNotifySubject
            .map { Reactor.Action.resetNotify }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reqeusetNotification
            .observe(on: MainScheduler.asyncInstance)
            .map { Reactor.Action.checkNotificationPermission }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addObservable(name: .updateFCMToken)
            .observe(on: MainScheduler.asyncInstance)
            .map { Reactor.Action.checkNotificationPermission }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, isLoad in
                vc.setIndicatorAnimating(isStart: isLoad)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, err in
                vc.alertManager.showDefatulErrorMessage()
            })
            .disposed(by: disposeBag)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        trackingTapVC()
    }
    
    private func trackingTapVC() {
        guard let currentVC = UIApplication.shared.topVC,
              let screenVC = currentVC as? BaseViewController else { return }
        ScreenTracking.track(with: screenVC)
    }
}

// MARK: - Helper
extension MainTabBarController {
    func viewController<T: UIViewController>(ofType type: T.Type) -> T? {
        let navs = viewControllers as? [UINavigationController] ?? []

        for nav in navs {
            if let matched = nav.viewControllers.first(where: { $0 is T }) as? T {
                return matched
            }
        }
        
        return nil
    }
}

extension MainTabBarController {
    // 초대링크를 통해서 접속한 경우
    func joinMeet(code: String) {
        joinMeetSubject.onNext(code)
    }
    
    func resetNotify() {
        resetNotifySubject.onNext(())
    }
}
