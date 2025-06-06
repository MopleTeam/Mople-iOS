//
//  DetailGroupViewController.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class MeetDetailViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = MeetDetailViewReactor
    var disposeBag: DisposeBag = DisposeBag()

    // MARK: - Observables
    private let endFlow: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .bgPrimary
        return view
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .appStroke
        view.layer.makeCornes(radius: 16, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        return view
    }()
    
    private let thumbnailView: MeetDetailThumbnail = {
        let view = MeetDetailThumbnail(thumbnailSize: 56,
                                       thumbnailRadius: 12)
        view.setTitleLabel(font: FontStyle.Title2.semiBold,
                           color: .gray01)
        view.setSpacing(12)
        return view
    }()
    
    private let segment: DefaultSegmentedControl = {
        let buttonTitles = [L10n.Meetdetail.planlist, L10n.Meetdetail.reviwelist]
        let segControl = DefaultSegmentedControl(buttonTitles: buttonTitles)
        return segControl
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [thumbnailView, segment])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 24
        stackView.backgroundColor = .defaultWhite
        stackView.layer.makeShadow(opactity: 0.02, radius: 12, offset: .init(width: 0, height: 0))
        stackView.layer.makeCornes(radius: 16, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    
    private(set) var pageController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll,
                                        navigationOrientation: .horizontal)
        return pageVC
    }()
    
    private let addPlanButton: BaseButton = {
        let btn = BaseButton()
        btn.setImage(image: .addButton)
        btn.setRadius(27)
        btn.layer.zPosition = 1
        btn.layer.makeShadow(opactity: 0.02,
                             radius: 24,
                             offset: .init(width: 0, height: 0))
        return btn
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: MeetDetailViewReactor?) {
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
        setLayout()
        setupNavi()
    }
    
    private func setLayout() {
        self.add(child: pageController)
        self.view.addSubview(contentView)
        self.view.addSubview(addPlanButton)
        self.contentView.addSubview(borderView)
        self.contentView.addSubview(headerStackView)
        self.contentView.addSubview(pageController.view)
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
            
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
 
        segment.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(headerStackView).offset(1)
        }
        
        pageController.view.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        addPlanButton.snp.makeConstraints { make in
            make.size.equalTo(54)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(24)
        }
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
        self.setBarItem(type: .right, image: .list)
    }
}

// MARK: - Reactor Setup
extension MeetDetailViewController {

    func bind(reactor: MeetDetailViewReactor) {
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
        self.naviBar.rightItemEvent
            .map { Reactor.Action.flow(.pushMeetSetupView) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.segment.rx.tapped
            .map { index -> Reactor.Action in
                let isFirst = index == 0
                return .flow(.switchPage(isFuture: isFirst))
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
                
        self.thumbnailView.rx.imageTap
            .map { Reactor.Action.flow(.showMeetImage) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.addPlanButton.rx.tap
            .map { Reactor.Action.flow(.createPlan) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.naviBar.leftItemEvent
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.endFlow
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.thumbnailView.inviteButton.rx.tap
            .map { Reactor.Action.invite }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func setNotificationBind(_ reactor: Reactor) {
        NotificationManager.shared.addMeetObservable()
            .map { Reactor.Action.editMeet($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addObservable(name: .midnightUpdate)
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$meet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, meet in
                vc.thumbnailView.configure(with: .init(meet: meet))
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$inviteUrl)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { [weak self] url -> String? in
                guard let self,
                      let url else { return nil }
                return makeInviteMessage(with: url)
            }
            .drive(with: self, onNext: { vc, url in
                vc.showActivityViewController(items: [url])
            })
            .disposed(by: disposeBag)
        
        Observable.merge(reactor.pulse(\.$meetInfoLoaded),
                         reactor.pulse(\.$futurePlanLoaded),
                         reactor.pulse(\.$pastPlanLoaded))
        .skip(1)
        .asDriver(onErrorJustReturn: false)
        .filter { [weak self] isLoad in
            self?.indicator.isAnimating == false && isLoad
        }
        .map({ _ in true })
        .drive(self.rx.isLoading)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(reactor.pulse(\.$meetInfoLoaded),
                                 reactor.pulse(\.$futurePlanLoaded),
                                 reactor.pulse(\.$pastPlanLoaded))
        .skip(1)
        .filter({ meetInfoLoaded, futurePlanLoaded, pastPlanLoaded in
            meetInfoLoaded == false &&
            futurePlanLoaded == false &&
            pastPlanLoaded == false
        })
        .map({ _ in false })
        .asDriver(onErrorJustReturn: false)
        .drive(self.rx.isLoading)
        .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 에러 핸들링
    private func handleError(_ err: MeetDetailError) {
        switch err {
        case let .noResponse(err):
            alertManager.showResponseErrorMessage(err: err,
                                                 completion: { [weak self] in
                guard case .noResponse(let responseType) = err,
                      case .meet = responseType else { return }
                self?.endFlow.onNext(())
            })
        case let .midnight(err):
            alertManager.showDateErrorMessage(err: err)
        case .unknown:
            alertManager.showDefatulErrorMessage()
        }
    }
}

// MARK: - Invite
extension MeetDetailViewController {
    private func makeInviteMessage(with url: String) -> String {
        let inviteComment = L10n.Meetdetail.inviteMessage
        return inviteComment + "\n" + url
    }
    
    private func showActivityViewController(items: [Any]) {
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
    }
}
