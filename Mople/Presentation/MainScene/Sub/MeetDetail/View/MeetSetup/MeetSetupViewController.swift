//
//  MeetSetupViewController.swift
//  Mople
//
//  Created by CatSlave on 1/8/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class MeetSetupViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = MeetSetupViewReactor
    private var meetSetupReactor: MeetSetupViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let endFlow: PublishSubject<Void> = .init()
    private let deleteMeet: PublishSubject<Void> = .init()
    
    // MARK: - Variables
    private var isHost: Bool = false
    
    // MARK: - UI Components
    private let thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.makeLine(width: 1)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        return view
    }()
    
    private let meetNameButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Title3.semiBold,
                     normalColor: ColorStyle.Gray._01)
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
        label.backgroundColor = ColorStyle.BG.input
        label.textAlignment = .center
        return label
    }()
    
    private let memberListButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: "참여자 목록",
                     font: FontStyle.Title3.medium,
                     normalColor: ColorStyle.Gray._01)
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        btn.setBgColor(normalColor: ColorStyle.Default.white)
        btn.setLayoutMargins(inset: .init(top: 0, leading: 20, bottom: 0, trailing: 20))
        return btn
    }()
    
    private let memberCountLabel: IconLabel = {
        let label = IconLabel(icon: .listArrow,
                              iconSize: .init(width: 24, height: 24))
        label.setTitle(font: FontStyle.Title3.medium,
                       color: ColorStyle.Gray._06)
        label.setSpacing(4)
        label.setIconAligment(.right)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let deleteButton: BaseButton = {
        let btn = BaseButton()
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        btn.setBgColor(normalColor: ColorStyle.Default.white)
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
        sv.backgroundColor = ColorStyle.Default.white
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [subStackView, memberListButton, deleteButton])
        sv.axis = .vertical
        sv.spacing  = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.BG.secondary
        return sv
    }()
    
    // MARK: - LifeCycle
    init(title: String?,
         reactor: MeetSetupViewReactor) {
        super.init(title: title)
        self.meetSetupReactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
        setDeleteButtonAction()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setupNavi()
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
        self.setBarItem(type: .right, image: .invite)
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
        
        [memberListButton, deleteButton].forEach {
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
        deleteButton.setTitle(text: isHost ? "모임 삭제" : "모임 나가기",
                             font: FontStyle.Title3.medium,
                             normalColor: isHost ? ColorStyle.Default.red : ColorStyle.Gray._01)
    }
    
    private func setNameButtonImage() {
        guard isHost else { return }
        meetNameButton.setImage(image: .editPan)
        meetNameButton.isEnabled = true
    }
    
    private func setMemberCountLabel(_ memberCount: Int?) {
        guard let memberCount else { return }
        memberCountLabel.text = "\(memberCount)명"
    }
    
    private func setSinceLabel(_ sinceDayCount: Int?) {
        let sinceCount = String(sinceDayCount ?? 0)
        let text = "우리가 추억을 쌓은지 \(sinceCount) 일째"
        sinceDayLabel.attributedText = NSMutableAttributedString.makeHighlightText(fullText: text,
                                                                                   highlightText: sinceCount,
                                                                                   highlightFont: FontStyle.Body1.bold)
    }
    
    // MARK: - Action
    private func setDeleteButtonAction() {
        deleteButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.handleDeleteMeet()
            })
            .disposed(by: disposeBag)
    }
    
    private func handleDeleteMeet() {
        if isHost {
            showDeleteAlert()
        } else {
            deleteMeet.onNext(())
        }
    }
}

// MARK: - Reactor Setup
extension MeetSetupViewController {
    private func setReactor() {
        reactor = meetSetupReactor
    }
    
    func bind(reactor: MeetSetupViewReactor) {
        inputBind(reactor: reactor)
        outputBind(reactor: reactor)
        setNotification(reactor: reactor)
    }
    
    private func inputBind(reactor: Reactor) {
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
        
        memberListButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.memberList) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        meetNameButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.flow(.editMeet) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func outputBind(reactor: Reactor) {
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
    
    private func setNotification(reactor: Reactor) {
        EventService.shared.addMeetObservable()
            .map { Reactor.Action.editMeet($0) }
            .bind(to: reactor.action)
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
    private func showDeleteAlert() {
        let action: DefaultAction = .init(text: "모임삭제",
                                          tintColor: ColorStyle.Default.white,
                                          bgColor: ColorStyle.App.secondary,
                                          completion: { [weak self] in
            self?.deleteMeet.onNext(())
        })
        
        alertManager.showAlert(title: "모임을 삭제할까요?",
                               subTitle: "해당 모임에 대한 모든 기록을 복구할 수 없어요",
                               defaultAction: .init(text: "취소"),
                               addAction: [action])
    }
}

