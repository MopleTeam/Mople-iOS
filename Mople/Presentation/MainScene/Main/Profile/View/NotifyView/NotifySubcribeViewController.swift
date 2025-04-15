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
    private var notifySubscribeReactor: NotifySubscribeViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var notifyActiveButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: "알람을 활성화하고  일정관리에 도움을 받아보세요",
                     font: FontStyle.Body1.regular,
                     normalColor: ColorStyle.Gray._04)
        btn.setRadius(8)
        btn.setBgColor(normalColor: ColorStyle.BG.input)
        return btn
    }()
    
    private let meetNotiButton: CheckView = {
        let view = CheckView()
        view.setTitle("모임 알림")
        view.setSubTitle("모임에 관련된 알림")
        return view
    }()
    
    private let planNotiButton: CheckView = {
        let view = CheckView()
        view.setTitle("일정 알림")
        view.setSubTitle("다가오는 일정이나 변동사항에 대한 알림")
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
    init(reactor: NotifySubscribeViewReactor) {
        super.init(title: "알림 관리 뷰")
        notifySubscribeReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function, #line, "Path : #0414 ")
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
    private func setReactor() {
        reactor = notifySubscribeReactor
    }
    
    func bind(reactor: NotifySubscribeViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
        enterForeground(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
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
    
    private func outputBind(_ reactor: Reactor) {
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

    private func enterForeground(_ reactor: Reactor) {
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .map { _ in Reactor.Action.checkNotification }
            .bind(to: reactor.action)
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

