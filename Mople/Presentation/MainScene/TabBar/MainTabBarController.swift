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
        view.setDynamicBorder(width: 1, color: .appStroke)
        view.isUserInteractionEnabled = false
        return view
    }()

    #if DEV && DEBUG
    // MARK: - Mock Toggle Button (Dev Only)
    private let mockToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        button.layer.zPosition = 100
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    private var mockButtonInitialCenter: CGPoint = .zero
    #endif
    
    // MARK: - LifeCycle
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
//        self.traitOverrides.horizontalSizeClass = .compact
//        self.traitOverrides.horizontalSizeClass = .compact
        
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
        self.tabBar.backgroundColor = .bgPrimary
        self.tabBar.addSubview(borderView)

        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        borderView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(tabBar.snp.horizontalEdges)
            make.bottom.equalTo(tabBar.snp.bottom)
            make.top.equalTo(tabBar.snp.top).offset(-1)
        }

        #if DEV && DEBUG
        setupMockToggleButton()
        #endif
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

// MARK: - Mock Toggle (Dev Only)
#if DEV && DEBUG
extension MainTabBarController {

    func setupMockToggleButton() {
        self.view.addSubview(mockToggleButton)

        mockToggleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(tabBar.snp.top).offset(-16)
            make.width.height.equalTo(48)
        }

        updateMockButtonAppearance(isMock: MockDataManager.shared.useMockData)

        mockToggleButton.addTarget(self,
                                   action: #selector(didTapMockToggle),
                                   for: .touchUpInside)

        // 드래그로 위치 이동 가능
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handleMockButtonDrag(_:)))
        mockToggleButton.addGestureRecognizer(panGesture)

        // 상태 변경 구독
        MockDataManager.shared.isMockMode
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, isMock in
                vc.updateMockButtonAppearance(isMock: isMock)
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapMockToggle() {
        MockDataManager.shared.toggle()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        let isMock = MockDataManager.shared.useMockData
        let mode = isMock ? "Mock" : "Live"
        let alert = UIAlertController(
            title: "\(mode) 모드 전환",
            message: "새로 진입하는 화면부터 \(mode) 데이터가 적용됩니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func updateMockButtonAppearance(isMock: Bool) {
        let title = isMock ? "Mock" : "Live"
        let color: UIColor = isMock ? .systemOrange : .systemBlue
        mockToggleButton.setTitle(title, for: .normal)
        mockToggleButton.backgroundColor = color
    }

    @objc private func handleMockButtonDrag(_ gesture: UIPanGestureRecognizer) {
        guard let button = gesture.view else { return }
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .began:
            mockButtonInitialCenter = button.center
        case .changed:
            button.center = CGPoint(x: mockButtonInitialCenter.x + translation.x,
                                    y: mockButtonInitialCenter.y + translation.y)
        case .ended, .cancelled:
            // 화면 밖으로 나가지 않도록 보정
            let safeArea = view.safeAreaLayoutGuide.layoutFrame
            var finalCenter = button.center
            let halfSize = button.bounds.width / 2
            finalCenter.x = max(safeArea.minX + halfSize, min(safeArea.maxX - halfSize, finalCenter.x))
            finalCenter.y = max(safeArea.minY + halfSize, min(tabBar.frame.minY - halfSize, finalCenter.y))

            // SnapKit 제약조건 해제 후 frame 기반으로 전환
            button.snp.removeConstraints()

            UIView.animate(withDuration: 0.2) {
                button.center = finalCenter
            }
        default:
            break
        }
    }
}
#endif
