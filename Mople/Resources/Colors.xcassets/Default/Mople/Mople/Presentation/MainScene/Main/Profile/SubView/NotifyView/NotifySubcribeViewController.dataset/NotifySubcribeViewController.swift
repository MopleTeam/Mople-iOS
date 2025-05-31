//
//  NotifyViewController.swift
//  Group
//
//  Created by CatSlave on 10/24/24.
//

import UIKit
import RxSwift
import ReactorKit

final class NotifySubcribeViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = NotifySubscribeViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var notifyActiveButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: L10n.Notify.active,
                     font: FontStyle.Body1.regular,
                     normalColor: .gray04)
        btn.setRadius(8)
        btn.setBgColor(normalColor: .bgInput)
        return btn
    }()
    
    private let meetNotiButton: DefaultSwitchView = {
        let view = DefaultSwitchView()
        view.setTitle(L10n.Notify.meet)
        view.setSubTitle(L10n.Notify.meetInfo)
        return view
    }()
    
    private let planNotiButton: DefaultSwitchView = {
        let view = DefaultSwitchView()
        view.setTitle(L10n.Notify.plan)
        view.setSubTitle(L10n.Notify.planInfo)
        return view
    }()
    
    private lazy var checkStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [meetNotiButton, planNotiButton])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [checkStackView])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: NotifySubscribeViewReactor) {
        super.init(screenName: screenName,
                   title: title)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setNaviItem()
        setLayout()
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    private func setLayout() {
        self.view.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}

// MARK: - Reactor Setup
extension NotifySubcribeViewController {
    func bind(reactor: NotifySubscribeViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
        setNotificationBind(reactor)
    }

    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        naviBar.leftItemEvent
            .map({ Reactor.Action.endFlow })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        meetNotiButton.rx.changeValue
            .map({ Reactor.Action.subscribe(type: .meet, isSubscribe: $0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        planNotiButton.rx.changeValue
            .map({ Reactor.Action.subscribe(type: .plan, isSubscribe: $0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        notifyActiveButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: {
                AppSettingOpener.openAppSettings()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addEnterForeGroundObservable()
            .map { _ in Reactor.Action.updateNotification }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$isAllowPermissions)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, isAllow in
                vc.handleNotifyPermission(isAllow: isAllow)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$subscribes)
            .asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { vc, subscribes in
                vc.setSubscribe(with: subscribes)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
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

// MARK: - Subscribe Update
extension NotifySubcribeViewController {
    
    // MARK: - 알림 설정 유도 버튼 활성화
    private func handleNotifyPermission(isAllow: Bool) {
        if isAllow {
            removeNotifyActiveButton()
        } else {
            addNotifyActiveButton()
        }
        
        setSubscribeEnalbe(isAllow: isAllow)
    }
    
    private func addNotifyActiveButton() {
        guard mainStackView.arrangedSubviews.contains(
            where: { $0 == notifyActiveButton }) == false else { return }
        mainStackView.insertArrangedSubview(notifyActiveButton, at: 0)
        notifyActiveButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    private func removeNotifyActiveButton() {
        guard mainStackView.arrangedSubviews.contains(
            where: { $0 == notifyActiveButton }) else { return }
        mainStackView.removeArrangedSubview(notifyActiveButton)
        notifyActiveButton.removeFromSuperview()
    }
    
    private func setSubscribeEnalbe(isAllow: Bool) {
        [meetNotiButton, planNotiButton].forEach {
            $0.rx.isEnabled.onNext(isAllow)
        }
    }
    
    // MARK: - 구독상태 설정
    private func setSubscribe(with subscribe: Set<SubscribeType>) {
        let meetSubscribe = subscribe.contains { $0 == .meet }
        let planSubscribe = subscribe.contains { $0 == .plan }
        
        meetNotiButton.setSubscribe(isSubscribe: meetSubscribe)
        planNotiButton.setSubscribe(isSubscribe: planSubscribe)
    }
}

