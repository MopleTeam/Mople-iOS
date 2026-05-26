//
//  DetailGroupViewController.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import Domain
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

    // 본문 컨테이너 (네비바 아래 전체)
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .bgSecondary
        return view
    }()

    // 네비 중앙: 모임 썸네일 + 이름
    private let naviTitleView = MeetDetailNaviTitleView()

    // 네비 우측 확성기 버튼 (rightButton(햄버거) 왼쪽에 배치)
    private let megaphoneButton: UIButton = {
        let btn = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "megaphone.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .text01
        return btn
    }()

    // 확성기 배지 점 (공지 존재 시 노출)
    private let megaphoneBadge: UIView = {
        let dot = UIView()
        dot.backgroundColor = .appPrimary
        dot.layer.cornerRadius = 4
        dot.isHidden = true
        return dot
    }()

    // 작성 유도 툴팁 (모임장 + 공지 없음 조건)
    private let composeTooltipView: UIView = {
        let v = UIView()
        v.backgroundColor = .bgPrimary
        v.layer.cornerRadius = 8
        v.layer.makeShadow(opactity: 0.08, radius: 8, offset: .init(width: 0, height: 2))
        v.isHidden = true
        return v
    }()

    private let composeTooltipLabel: UILabel = {
        let label = UILabel()
        label.text = "공지를 작성해보세요."
        label.font = FontStyle.Body2.medium
        label.textColor = .text02
        return label
    }()

    // 공지 미리보기 카드
    private let noticePreviewView = MeetDetailNoticePreviewView()

    // pill 세그먼트
    private let pillSegment = MeetDetailPillSegment(
        titles: [L10n.Meetdetail.planlist, L10n.Meetdetail.reviwelist]
    )

    // 일정/리뷰 페이지 영역
    private(set) var pageController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll,
                                          navigationOrientation: .horizontal)
        return pageVC
    }()

    // 일정 추가 FAB
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
                   title: nil)  // 커스텀 중앙 뷰를 쓰므로 기본 title은 비워둔다
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
        setupNavi()
        setLayout()
    }

    private func setLayout() {
        self.add(child: pageController)
        view.addSubview(contentView)
        view.addSubview(addPlanButton)

        contentView.addSubview(noticePreviewView)
        contentView.addSubview(pillSegment)
        contentView.addSubview(pageController.view)

        contentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }

        // 공지 미리보기 카드 — 기본 hidden, pinnedNotice 존재 시만 표시
        noticePreviewView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        noticePreviewView.isHidden = true

        pillSegment.snp.makeConstraints { make in
            make.top.equalTo(noticePreviewView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
        }

        pageController.view.snp.makeConstraints { make in
            make.top.equalTo(pillSegment.snp.bottom).offset(16)
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

        // 중앙: 모임 이미지 + 이름
        self.naviBar.addSubview(naviTitleView)
        naviTitleView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        // 확성기 (햄버거 rightButton 좌측에 배치: 20 padding + 40 rightButton + 8 gap = 68)
        self.naviBar.addSubview(megaphoneButton)
        megaphoneButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(68)
            make.size.equalTo(40)
        }

        // 배지 점 — 확성기 우상단
        megaphoneButton.addSubview(megaphoneBadge)
        megaphoneBadge.snp.makeConstraints { make in
            make.size.equalTo(8)
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
        }

        // 작성 유도 툴팁 — 확성기 버튼 아래
        composeTooltipView.addSubview(composeTooltipLabel)
        composeTooltipLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
        view.addSubview(composeTooltipView)
        composeTooltipView.snp.makeConstraints { make in
            make.top.equalTo(megaphoneButton.snp.bottom).offset(4)
            make.centerX.equalTo(megaphoneButton)
        }
    }

    // MARK: - Gesture
    public func configureEdgeGesture() {
        guard let currentNavi = self.findCurrentNavigation(),
              let appNavi = currentNavi as? AppNaviViewController else { return }

        pageController.viewControllers?.forEach {
            guard let gestureVC = $0 as? EdgeGestureConfigurable else { return }
            gestureVC.configureEdgeGesture(appNavi.edgeGesture)
        }
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

        self.pillSegment.selectedIndexChanged
            .map { index -> Reactor.Action in
                let isFuture = index == 0
                return .flow(.switchPage(isFuture: isFuture))
            }
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

        // 확성기 → 공지 리스트 진입
        self.megaphoneButton.rx.tap
            .map { Reactor.Action.flow(.openNoticeList) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // 미리보기 카드 → 공지 상세 진입
        self.noticePreviewView.tapEvent
            .map { Reactor.Action.flow(.openNoticeDetail) }
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
                vc.applyMeet(meet)
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

    // 모임 데이터 → UI 반영 (네비 중앙, 공지 카드, 확성기 배지, 작성 유도 툴팁)
    private func applyMeet(_ meet: Meet) {
        naviTitleView.configure(name: meet.meetSummary?.name,
                                imagePath: meet.meetSummary?.imagePath)

        let pinned = meet.pinnedNotice
        let hasNotice = pinned != nil

        // 공지 미리보기 카드
        noticePreviewView.isHidden = !hasNotice
        if let content = pinned?.content {
            noticePreviewView.configure(content: content)
        }

        // 확성기 파란 점 배지
        megaphoneBadge.isHidden = !hasNotice

        // 모임장 + 공지 없음 → 작성 유도 툴팁
        composeTooltipView.isHidden = !(meet.isCreator && !hasNotice)
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
