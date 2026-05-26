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

    // 공지 카드를 20pt 좌우 인셋으로 감싸는 wrapper (UIStackView가 width를 full로 강제하므로 필요)
    private let noticePreviewContainer = UIView()

    // 공지 + pill을 하나의 헤더 단위로 묶음. 자식 스크롤 시 transform으로 위로 슬라이드해 사라지고 다시 나타남.
    // 공지가 없을 때는 noticePreviewContainer가 isHidden 처리되어 UIStackView가 자동 collapse.
    private lazy var headerContainer: UIStackView = {
        let pillWrap = UIView()
        pillWrap.addSubview(pillSegment)
        pillSegment.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
        }

        noticePreviewContainer.addSubview(noticePreviewView)
        noticePreviewView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }

        let sv = UIStackView(arrangedSubviews: [noticePreviewContainer, pillWrap])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.spacing = 16
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return sv
    }()

    // 자식 스크롤 시 헤더가 사라질 수 있는 최대 거리 (= 헤더 전체 높이)
    private var headerMaxHide: CGFloat { headerContainer.bounds.height }
    private var currentHideAmount: CGFloat = 0

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

        contentView.addSubview(headerContainer)
        contentView.addSubview(pageController.view)

        contentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }

        // 헤더 (공지 미리보기 + pill 세그먼트) — 기본은 공지 hidden 상태로 시작
        noticePreviewContainer.isHidden = true

        headerContainer.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }

        pageController.view.snp.makeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom)
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

        // 공지 미리보기 카드 (UIStackView가 isHidden 자동 collapse → 헤더 높이도 함께 변동)
        noticePreviewContainer.isHidden = !hasNotice
        noticePreviewView.isHidden = !hasNotice
        if let content = pinned?.content {
            noticePreviewView.configure(content: content)
        }

        // 헤더 높이가 바뀔 수 있으므로 sticky 상태도 재계산
        applyHide(currentHideAmount)

        // 확성기 파란 점 배지
        megaphoneBadge.isHidden = !hasNotice

        // 모임장 + 공지 없음 → 작성 유도 툴팁
        composeTooltipView.isHidden = !(meet.isCreator && !hasNotice)
    }

    // MARK: - Sticky Header
    // Coordinator가 page child VC들을 생성한 직후 wire-up. 두 자식 모두 같은 콜백으로 묶어
    // 헤더 transform이 한 곳에서만 변하도록 한다.
    func attachChildScrollObservers(_ children: UIViewController...) {
        for child in children {
            if let plan = child as? MeetPlanListViewController {
                plan.onScrollChange = { [weak self] offset in
                    self?.handleChildScroll(offset)
                }
            } else if let review = child as? MeetReviewListViewController {
                review.onScrollChange = { [weak self] offset in
                    self?.handleChildScroll(offset)
                }
            }
        }
    }

    // 자식 VC(MeetPlanListVC / MeetReviewListVC)가 emit하는 contentOffset.y를 받아
    // 헤더가 위로 슬라이드되며 사라지고, 아래로 당기면 다시 나타나는 동작을 만든다.
    private func handleChildScroll(_ offset: CGFloat) {
        let clamped = max(0, min(headerMaxHide, offset))
        guard abs(clamped - currentHideAmount) > 0.5 else { return }
        currentHideAmount = clamped
        applyHide(clamped)
    }

    private func applyHide(_ amount: CGFloat) {
        let translate = CGAffineTransform(translationX: 0, y: -amount)
        headerContainer.transform = translate
        pageController.view.transform = translate
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
