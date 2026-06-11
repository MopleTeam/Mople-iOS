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
    // SF Symbol에서 디자이너가 export한 .meetMegaphone 에셋으로 교체
    private let megaphoneButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.meetMegaphone, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
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

    // 작성 유도 툴팁 (모임장 + 공지 없음 조건). 위쪽에 삼각형 꼬리가 달린 말풍선.
    private let composeTooltipView: TooltipBalloonView = {
        let v = TooltipBalloonView(text: "공지를 작성해보세요.")
        v.isHidden = true
        return v
    }()

    // 공지 미리보기 카드
    private let noticePreviewView = MeetDetailNoticePreviewView()

    // pill 세그먼트
    private let pillSegment = MeetDetailPillSegment(
        titles: [L10n.Meetdetail.planlist, L10n.Meetdetail.reviwelist]
    )

    // 공지 카드 wrapper. height constraint와 isHidden을 함께 토글해서 가변 처리.
    // 기본은 isHidden = true / height = 0 → mock 도착 전에도 약속 탭이 sticky 위치(navi 아래 16)에 있음.
    // pinnedNotice 도착 시 applyMeet에서 isHidden = false / height = 80으로 동시 전환.
    private let noticePreviewContainer: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.isHidden = true
        return v
    }()
    private var noticeHeightConstraint: Constraint?

    // pill을 감싸는 wrapper. frame.maxY/minY를 측정해서 inset과 hideMax를 계산.
    private let pillWrap = UIView()

    // 공지 + pill을 하나의 헤더 단위로 묶음. 자식 스크롤 시 transform으로 위로 슬라이드.
    // 공지 height가 0(기본)이면 wrapper도 0, 80이면 80 — 그에 따라 pillWrap.minY/maxY가 자동 변동.
    // PassThroughStackView로 만들어서 자체 영역의 hit는 통과시키고, 자식 view만 터치를 받게 한다.
    private lazy var headerContainer: PassThroughStackView = {
        pillWrap.addSubview(pillSegment)
        pillSegment.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
        }

        noticePreviewContainer.addSubview(noticePreviewView)
        noticePreviewView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(80)
        }
        noticePreviewContainer.snp.makeConstraints { make in
            self.noticeHeightConstraint = make.height.equalTo(0).constraint
        }

        let sv = PassThroughStackView(arrangedSubviews: [noticePreviewContainer, pillWrap])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.spacing = 16
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return sv
    }()

    // PageController 내부 scrollView contentOffset KVO observer.
    // 사용자 swipe progress를 selectedPill 보간 이동에 사용.
    private var pageScrollObservation: NSKeyValueObservation?

    // 자식 스크롤에 따라 헤더 transform 조정. 약속 탭은 sticky로 navi 아래 16pt에서 멈춘다.
    // - inset.top = 약속 탭 maxY + spacing → 첫 셀이 약속 탭 아래에서 시작 (겹치지 않음)
    // - hideMax   = 약속 탭 sticky 도달까지 필요한 transform 거리 (= 약속 탭 minY - 16)
    //   inset != hideMax 이므로 1:1 매핑은 아니지만, swipe 시작과 동시에 transform이 진행되고
    //   sticky 도달 후 추가 swipe에서는 tableView만 정상 스크롤된다.
    private var lastPropagatedInset: CGFloat = -1
    private var lastPropagatedHideMax: CGFloat = -1
    private var currentHideAmount: CGFloat = 0
    private weak var planChild: MeetPlanListViewController?
    private weak var reviewChild: MeetReviewListViewController?

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        propagateHeaderInsetIfNeeded()
        alignTooltipTailToMegaphone()
    }

    // tooltip의 trailing이 화면 우측 inset에 고정되어 있으므로, tail의 가로 위치를
    // megaphoneButton의 centerX와 매칭시켜야 확성기를 정확히 가리킨다.
    private func alignTooltipTailToMegaphone() {
        guard composeTooltipView.bounds.width > 0 else { return }
        let megaphoneCenter = megaphoneButton.convert(
            CGPoint(x: megaphoneButton.bounds.midX, y: 0),
            to: composeTooltipView
        )
        composeTooltipView.tailCenterX = megaphoneCenter.x
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 첫 layout 사이클에서 stale일 수 있는 height를 viewDidAppear 시점에 한 번 더 측정
        propagateHeaderInsetIfNeeded()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        // setupNavi에서 add한 composeTooltipView가 setLayout에서 나중에 add된 contentView/addPlanButton에
        // 가려지지 않도록 가장 앞으로 가져온다.
        view.bringSubviewToFront(composeTooltipView)
        composeTooltipView.layer.zPosition = 2
    }

    private func setLayout() {
        self.add(child: pageController)
        view.addSubview(contentView)
        view.addSubview(addPlanButton)

        // pageController.view는 contentView 전체를 채운다 (height 고정).
        // 헤더는 그 위에 overlay로 떠서 transform.y로만 슬라이드 → 페이지 컨텐츠 영역은 일정.
        contentView.addSubview(pageController.view)
        contentView.addSubview(headerContainer)

        contentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }

        // 헤더 (공지 미리보기 + pill 세그먼트) — 공지 height는 기본 0 (constraint로 처리)
        headerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        headerContainer.layer.zPosition = 1

        pageController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

        // 작성 유도 툴팁 — 확성기 버튼 아래.
        // 조건 1: 말풍선의 trailing = 확성기 trailing (오른쪽 끝이 확성기와 정렬)
        // 조건 2: tail의 centerX = 확성기의 centerX (꼬리가 확성기 중앙을 가리킴)
        //         → tail은 viewDidLayoutSubviews의 alignTooltipTailToMegaphone()에서 동적 설정
        view.addSubview(composeTooltipView)
        composeTooltipView.snp.makeConstraints { make in
            make.top.equalTo(megaphoneButton.snp.bottom).offset(4)
            make.trailing.equalTo(megaphoneButton.snp.trailing)
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

        // PageController의 paging pan gesture도 edge gesture가 먼저 인식되도록 양보.
        // dataSource 활성화 이후 좌측 edge swipe로 modal dismiss가 안 되는 충돌을 해결.
        for sv in pageController.view.subviews {
            if let scrollView = sv as? UIScrollView {
                scrollView.panGestureRecognizer.require(toFail: appNavi.edgeGesture)
                break
            }
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

        // 공지 핀 토글 알림 → 모임상세 pinnedNotice 갱신
        NotificationManager.shared.addNoticeObservable()
            .map { Reactor.Action.applyNotice($0) }
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

        if let content = pinned?.content {
            noticePreviewView.configure(content: content)
        }

        // 공지 카드 토글:
        //   isHidden: UIStackView가 자동 collapse — 자식 + 인접 spacing이 함께 빠짐
        //            → 약속 탭이 navi 바로 아래(layoutMargin.top 16만)에 위치
        //   height : 명시적 안전망 (isHidden 처리 외 상황에서도 layout 명확)
        let targetHeight: CGFloat = hasNotice ? 80 : 0
        noticePreviewContainer.isHidden = !hasNotice
        noticeHeightConstraint?.update(offset: targetHeight)
        view.layoutIfNeeded()
        propagateHeaderInsetIfNeeded()

        // 헤더 높이가 바뀔 수 있으므로 sticky 상태도 재계산
        applyHide(currentHideAmount)

        // 확성기 파란 점 배지 — 향후 개발 예정 (서버에 unread 신호가 들어오면 활성화)
        megaphoneBadge.isHidden = true

        // 모임장 + 공지 없음 → 작성 유도 툴팁
        // 단 모임별로 "첫 진입 1회"만 표시 (UserDefaults에 seen 플래그 기록).
        let shouldShowTooltip = meet.isCreator && !hasNotice
            && !NoticeTooltipMemory.hasSeen(meetId: meet.meetSummary?.id)
        composeTooltipView.isHidden = !shouldShowTooltip
        if shouldShowTooltip {
            NoticeTooltipMemory.markSeen(meetId: meet.meetSummary?.id)
        }
    }

    // MARK: - Sticky Header
    // Coordinator가 page child VC들을 생성한 직후 wire-up.
    // 두 자식 모두 같은 콜백으로 묶어 헤더 transform이 한 곳에서만 변하도록 한다.
    // 그리고 layout 사이클 후 setTopContentInset(headerHeight)로 자식 tableView의 상단을 비워둔다.
    func attachChildScrollObservers(_ children: UIViewController...) {
        for child in children {
            if let plan = child as? MeetPlanListViewController {
                planChild = plan
                plan.onScrollChange = { [weak self] offset in
                    self?.handleChildScroll(offset)
                }
            } else if let review = child as? MeetReviewListViewController {
                reviewChild = review
                review.onScrollChange = { [weak self] offset in
                    self?.handleChildScroll(offset)
                }
            }
        }
        // 즉시 layout을 강제해서 attach 직후에도 인셋 전파가 일어나도록 한다.
        // setNeedsLayout만으로는 다음 runloop으로 미뤄지고, 그 사이 child가 그려지면
        // contentInset 없이 잘못된 위치에서 첫 표시될 수 있다.
        view.layoutIfNeeded()
        propagateHeaderInsetIfNeeded()

        // 인터랙티브 swipe ↔ pill 트래킹 setup
        setupInteractivePageSwipe()
    }

    // PageController 좌우 swipe와 pill 세그먼트 selectedPill을 동기화한다.
    // - dataSource로 양방향 swipe 활성화 (plan ↔ review)
    // - delegate로 transition 완료 후 selectedIndex 동기화
    // - 내부 scrollView contentOffset KVO로 progress 추출 → pill에 보간 이동 적용
    private func setupInteractivePageSwipe() {
        pageController.dataSource = self
        pageController.delegate = self

        for sv in pageController.view.subviews {
            guard let scrollView = sv as? UIScrollView else { continue }
            pageScrollObservation = scrollView.observe(\.contentOffset, options: [.new]) { [weak self] sv, _ in
                self?.handlePageInteractiveScroll(sv)
            }
            break
        }
    }

    // UIPageViewController scrollView 동작:
    //   정상 상태 contentOffset.x = bounds.width (가운데 페이지가 visible)
    //   왼→오 swipe: x < bounds.width (이전 페이지 방향)
    //   오→왼 swipe: x > bounds.width (다음 페이지 방향)
    private func handlePageInteractiveScroll(_ sv: UIScrollView) {
        let pageWidth = sv.bounds.width
        guard pageWidth > 0 else { return }
        let progress = (sv.contentOffset.x - pageWidth) / pageWidth
        pillSegment.setInteractiveProgress(progress)
    }

    // 헤더 layout 변동 시(공지 hidden ↔ visible, 첫 표시 등) 자식 tableView에 inset 전파.
    // 두 값을 계산해 보관:
    //   inset   = 약속 탭 maxY + spacing (= pillWrap.frame.maxY + 16)
    //             → 자식 tableView contentInset.top. 셀이 약속 탭 아래에서 시작.
    //   hideMax = 약속 탭이 sticky 위치(navi 아래 16pt)까지 이동해야 하는 transform 거리
    //             = pillWrap.frame.minY - 16
    private func propagateHeaderInsetIfNeeded() {
        headerContainer.layoutIfNeeded()
        let inset = pillWrap.frame.maxY + 16
        let hideMax = max(0, pillWrap.frame.minY - 16)
        guard inset > 0,
              abs(inset - lastPropagatedInset) > 0.5 else { return }
        lastPropagatedInset = inset
        lastPropagatedHideMax = hideMax
        planChild?.setTopContentInset(inset)
        reviewChild?.setTopContentInset(inset)
    }

    // 자식 VC가 emit하는 contentOffset.y에 따라 헤더가 슬라이드되며 사라지고 다시 나타난다.
    // swipeDistance = offset + inset (사용자가 위로 swipe한 누적 거리, 0 이상)
    // hide          = min(hideMax, swipeDistance)
    // → swipe 0 ~ hideMax: 공지 사라지면서 약속 탭이 sticky 위치 도달
    // → swipe hideMax+:   sticky 유지, tableView만 자체 스크롤 (약속 탭 transform 더 안 됨)
    private func handleChildScroll(_ offset: CGFloat) {
        let inset = lastPropagatedInset
        let hideMax = lastPropagatedHideMax
        guard inset > 0 else { return }
        let swipeDistance = max(0, offset + inset)
        let hide = min(hideMax, swipeDistance)
        guard abs(hide - currentHideAmount) > 0.5 else { return }
        currentHideAmount = hide
        applyHide(hide)
    }

    private func applyHide(_ amount: CGFloat) {
        headerContainer.transform = CGAffineTransform(translationX: 0, y: -amount)
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

// MARK: - PassThroughStackView
// 자기 영역의 hit는 통과시키고 자식 view들의 hit만 잡는 UIStackView.
// 헤더 overlay 영역에서도 그 아래 tableView의 swipe가 동작하도록 한다.
final class PassThroughStackView: UIStackView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === self ? nil : hit
    }
}

// MARK: - UIPageViewController DataSource / Delegate (인터랙티브 swipe)
extension MeetDetailViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // review의 이전 = plan
        if viewController === reviewChild { return planChild }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // plan의 다음 = review
        if viewController === planChild { return reviewChild }
        return nil
    }
}

extension MeetDetailViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        // 전환 실패(복귀): transform reset만
        guard completed else {
            pillSegment.commitInteractiveTransition(to: pillSegment.selectedIndex)
            return
        }
        // 전환 성공: 현재 visible VC로 selectedIndex 확정
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        let newIndex: Int
        if currentVC === planChild { newIndex = 0 }
        else if currentVC === reviewChild { newIndex = 1 }
        else { return }
        pillSegment.commitInteractiveTransition(to: newIndex)
    }
}
