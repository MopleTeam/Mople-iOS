//
//  MeetSetupViewController.swift
//  Mople
//
//  Created by CatSlave on 1/8/25.
//

import UIKit
import Domain
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class MeetSetupViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = MeetSetupViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let endFlow: PublishSubject<Void> = .init()
    private let deleteMeet: PublishSubject<Void> = .init()
    private let transferMeet: PublishSubject<Void> = .init()
    
    // MARK: - Variables
    private var isHost: Bool = false
    
    // MARK: - UI Components
    private let thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.setDynamicBorder(width: 1)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        return view
    }()
    
    private let meetNameButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Title3.semiBold,
                     normalColor: .text01)
        btn.setLayoutMargins(inset: .zero)
        btn.isEnabled = false
        return btn
    }()
    
    private let spaceView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .horizontal)
        view.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return view
    }()
    
    private let sinceDayLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.backgroundColor = .bgInput
        label.textAlignment = .center
        return label
    }()
    
    private let memberListButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: L10n.memberList,
                     font: FontStyle.Title3.medium,
                     normalColor: .text01)
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        btn.setBgColor(normalColor: .bgPrimary)
        btn.setLayoutMargins(inset: .init(top: 0, leading: 20, bottom: 0, trailing: 20))
        return btn
    }()
    
    private let memberCountLabel: IconLabel = {
        let label = IconLabel(icon: .listArrow,
                              iconSize: .init(width: 24, height: 24))
        label.setTitle(font: FontStyle.Title3.medium,
                       color: .text04)
        label.setSpacing(4)
        label.rightIconAligment()
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let transferMeetButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: "모임 양도하기",
                     font: FontStyle.Title3.medium,
                     normalColor: .text01)
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        btn.setBgColor(normalColor: .bgPrimary)
        btn.setLayoutMargins(inset: .init(top: 0, leading: 20, bottom: 0, trailing: 20))
        btn.isHidden = true  // 기본적으로 숨김 (호스트일 때만 표시)
        return btn
    }()
    
    private let deleteButton: BaseButton = {
        let btn = BaseButton()
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        btn.setBgColor(normalColor: .bgPrimary)
        btn.setLayoutMargins(inset: .init(top: 0, leading: 20, bottom: 0, trailing: 20))
        return btn
    }()
    
    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailImage, meetNameButton])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStackView, sinceDayLabel])
        sv.axis = .vertical
        sv.spacing = 24
        sv.alignment = .leading
        sv.distribution = .fill
        sv.backgroundColor = .bgPrimary
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return sv
    }()
    
    private lazy var menuStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [memberListButton, transferMeetButton])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
//        sv.backgroundColor = .bgSecondary
//        sv.isLayoutMarginsRelativeArrangement = true
//        sv.layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [subStackView, menuStackView, deleteButton])
        sv.axis = .vertical
        sv.spacing  = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = .bgSecondary
        return sv
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: MeetSetupViewReactor) {
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
        setDeleteButtonAction()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setupNavi()
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
    }
    
    private func setLayout() {
        self.view.addSubview(mainStackView)
        self.memberListButton.addSubview(memberCountLabel)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        sinceDayLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        thumbnailImage.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        
        [memberListButton, transferMeetButton, deleteButton].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
        
        memberCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func setMeetInfo(_ meet: Meet) {
        thumbnailImage.kfSetimage(meet.meetSummary?.imagePath,
                                  defaultImageType: .meet)
        meetNameButton.title = meet.meetSummary?.name
        setMemberCountLabel(meet.memberCount)
        setSinceLabel(meet.sinceDays)
    }
    
    private func setLeaveButtonText() {
        deleteButton.setTitle(text: isHost
                              ? L10n.Meetdetail.delete
                              : L10n.Meetdetail.leave,
                              font: FontStyle.Title3.medium,
                              normalColor: isHost
                              ? .appRed
                              : .text01)
    }
    
    private func setNameButtonImage() {
        meetNameButton.setImage(image: isHost ? .editPan : nil)
        meetNameButton.isEnabled = isHost
        transferMeetButton.isHidden = !isHost  // 호스트일 때 모임 양도 버튼 표시
    }
    
    private func setMemberCountLabel(_ memberCount: Int?) {
        guard let memberCount else { return }
        memberCountLabel.text = L10n.peopleCount(memberCount)
    }
    
    private func setSinceLabel(_ sinceDayCount: Int?) {
        let sinceCount = sinceDayCount ?? 0
        let text = L10n.Meetdetail.sinceCount(sinceCount)
        sinceDayLabel.attributedText = NSMutableAttributedString
            .makeHighlightText(fullText: text,
                               highlightText: "\(sinceCount)",
                               highlightFont: FontStyle.Body1.bold)
    }
    
    // MARK: - Action
    private func setDeleteButtonAction() {
        deleteButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                if vc.isHost {
                    vc.showDeleteAlert()
                } else {
                    vc.showLeaverAlert()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Setup
extension MeetSetupViewController {

    func bind(reactor: MeetSetupViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
        setNotificationBind(reactor: reactor)
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
            .map { Reactor.Action.flow(.pop) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        deleteMeet
            .map { Reactor.Action.deleteMeet }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        transferMeet
            .map { Reactor.Action.flow(.transferMeet) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        memberListButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.memberList) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        meetNameButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.editMeet) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        transferMeetButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.transferMeet) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func setNotificationBind(reactor: Reactor) {
        NotificationManager.shared.addMeetObservable()
            .map { Reactor.Action.editMeet($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$meet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, meet in
                vc.setMeetInfo(meet)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isHost)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isHost in
                vc.isHost = isHost
                vc.setNameButtonImage()
                vc.setLeaveButtonText()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoading in
                vc.rx.isLoading.onNext(isLoading)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Error
    private func handleError(_ err: MeetSetupError) {
        switch err {
        case let .noResponse(err):
            alertManager.showResponseErrorMessage(err: err,
                                                  completion: { [weak self] in
                self?.endFlow.onNext(())
            })
        }
    }
}

// MARK: - Alert
extension MeetSetupViewController {
    private func showLeaverAlert() {
        let action: DefaultAlertAction = .init(
            text: L10n.Meetdetail.leave,
            textColor: .secondaryText,
            bgColor: .appSecondary,
            completion: { [weak self] in
                self?.deleteMeet.onNext(())
            })
        
        alertManager.showDefaultAlert(
            title: L10n.Meetdetail.leaveInfo,
            defaultAction: .init(text: L10n.no,
                                 textColor: .tertiaryText,
                                 bgColor: .appTertiary),
            addAction: [action])
    }
    
    private func showDeleteAlert() {
        let deleteAction: DefaultAlertAction = .init(
            text: L10n.Meetdetail.leave,
            textColor: .tertiaryText,
            bgColor: .appTertiary,
            completion: { [weak self] in
                self?.deleteMeet.onNext(())
            })
        
        let transferAction: DefaultAlertAction = .init(
            text: L10n.Meetdetail.transfer,
            textColor: .secondaryText,
            bgColor: .appSecondary,
            completion: { [weak self] in
                self?.transferMeet.onNext(())
            })
        
        alertManager.showDefaultAlert(
            title: L10n.Meetdetail.deleteInfo,
            subTitle: L10n.Meetdetail.deleteSubinfo,
            defaultAction: deleteAction,
            addAction: [transferAction])
    }
}
