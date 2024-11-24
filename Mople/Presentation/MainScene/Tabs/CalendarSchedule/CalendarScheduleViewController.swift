//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CalendarScheduleViewController: DefaultViewController, View {
    
    typealias Reactor = CalendarViewReactor
    
    private enum DistanceThreshold {
        static let weekToMonthDistance: CGFloat = 50.0
    }
    
    private enum VelocityThreshold {
        static let thresholdVelocity: CGFloat = 300.0
    }
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
    
    private let currentCalendar = DateManager.calendar
    private lazy var todayComponents = {
        var components = Date().getComponents()
        return components
    }()
    
    // MARK: - Observer
    private let scopeObserver: PublishSubject<Void> = .init()
    private let testScopeObserver: PublishSubject<Void> = .init()
    private let gsetrueTestScopeObserver: PublishSubject<CalendarViewController.pageChangeType> = .init()
    private let presentEventObserver: BehaviorRelay<Date?> = .init(value: nil)
    
    #warning("reactor외의 용도로 만드는 이유")
    // reactor는 제스처 업데이트와 같이 짧은 시간에 많은 값이 들어가는 경우 재진입 이슈 발생
    private let gestureObserver: PublishSubject<UIPanGestureRecognizer> = .init()
        
    // MARK: - UI Components
    private let headerButton: UIButton = {
        let view = UIButton()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = ColorStyle.BG.primary
        return view
    }()
    
    private let header: IconLabel = {
        let header = IconLabel(icon: .arrow, iconSize: 24)
        header.setTitle(font: FontStyle.Title3.semiBold,
                        color: ColorStyle.Gray._01)
        header.setIconAligment(.right)
        header.isUserInteractionEnabled = false
        return header
    }()
    
    // 캘린더
    private let calendarContainer = UIView()
    
    private lazy var calendarView: CalendarViewController = {
        let calendarView = CalendarViewController(reactor: reactor!,
                                                  gestureObserver: gestureObserver)
        
        calendarView.view.layer.cornerRadius = 16
        calendarView.view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return calendarView
    }()
    
    // 스케쥴 리스트 테이블 뷰
    private let scheduleListContainer = UIView()
    
    private lazy var scheduleListTableView: ScheduleTableViewController = {
        
        let scheduleListTableView = ScheduleTableViewController(reactor: reactor!)
        return scheduleListTableView
    }()
    
    // 구분선
    private let borderView = UIView()
    
    // MARK: - Gesture
    private lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    // MARK: - LifeCycle
    init(title: String,
         reactor: CalendarViewReactor) {
        super.init(title: title)
        self.reactor = reactor
    }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     override func viewDidLoad() {
         print(#function, #line)
         super.viewDidLoad()
         setupUI()
         setAction()
         setGesture()
     }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function, #line)
        super.viewWillDisappear(animated)
        resetPresentDate()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavi()
        setLayout()
        setContainer()
        setHeaderDate()
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left, image: .arrowBack)
        self.setBarItem(type: .right, image: .calendar)
        self.hideBaritem(type: .left, isHidden: true)
    }
    
    private func setLayout() {
        self.view.addSubview(headerButton)
        self.headerButton.addSubview(header)
        self.view.addSubview(calendarContainer)
        self.view.addSubview(scheduleListContainer)
        self.view.addSubview(borderView)
                        
        headerButton.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
        
        header.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        calendarContainer.snp.makeConstraints { make in
            make.top.equalTo(headerButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(360)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainer.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        scheduleListContainer.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setContainer() {
        addCalendarView()
        addScheduleListView()
    }
    
    private func addCalendarView() {
        addChild(calendarView)
        calendarContainer.addSubview(calendarView.view)
        calendarView.didMove(toParent: self)
        calendarView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addScheduleListView() {
        addChild(scheduleListTableView)
        scheduleListContainer.addSubview(scheduleListTableView.view)
        scheduleListTableView.didMove(toParent: self)
        scheduleListTableView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setHeaderDate() {
        setHeaderLabel(date: Date().getComponents())
    }
    
    // MARK: - Binding
    func bind(reactor: CalendarViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        reactor.pulse(\.$calendarHeight)
            .compactMap({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, height in
                vc.updateCalendarView(height)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$scope)
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, scope in
                vc.updateMainView(scope)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$changedPage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, date in
                vc.setHeaderLabel(date: date)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isLoad in
                vc.rx.isLoading.onNext(isLoad)
                vc.checkIsPresent(isLoad)
            })
            .disposed(by: disposeBag)
    }
    
    private func outputBind(_ reactor: Reactor) {
        
        self.scopeObserver
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestScopeSwitch(type: .gesture) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rightItemEvent
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestScopeSwitch(type: .buttonTap) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.leftItemEvent
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestScopeSwitch(type: .buttonTap) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.presentEventObserver
            .observe(on: MainScheduler.instance)
            .compactMap({ $0 })
            .map { Reactor.Action.requestPresentEvent(lastRecentDate: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.testScopeObserver
            .observe(on: MainScheduler.instance)
            .map { Reactor.Action.requestScopeSwitch(type: .buttonTap) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action
    private func setAction() {
        self.gsetrueTestScopeObserver
            .subscribe(with: self, onNext: { vc, type in
                vc.calendarView.handlePageChange(type)
            })
            .disposed(by: disposeBag)
        
        headerButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.presentDatePicker()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Gesture Setup
    
    // month
    // - y : 0 보다 작을 때 (위로 제스처) 스코프 전환
    // - x
    //    제스처 시작
    //      - 캘린더(컬렉션 뷰) contentOffset 조정
    //    제스처 끝 (가속도)
    //      - 0 이상이라면 다음 달
    //      - 0 이하라면 이전 달
    //      - 0이라면 이동거리 계산 (이동거리 절댓값 비교 후 크기의 반 이상이라면 이동)
    // week
    // - x
    //    제스처 끝 (이동거리 (적절 값 계산해보기) 계산 후
    //    가속도는 ended 지점에서 핸들링하기가 부적절
    //    - 좌측에서 우측으로 제스처를 취했지만 때는 순간 약간 좌측으로 쏠리면 가속도가 -로 나옴
    
    var isHorizonGesture: Bool = false {
        didSet {
            print(#function, #line, "#7 가로 스크롤 중입니까? : \(isHorizonGesture)" )
        }
    }
    
    var isVerticalGesture: Bool = false {
        didSet {
            print(#function, #line, "#7 세로 스크롤 중입니까? : \(isVerticalGesture)" )
        }
    }
    
    var startCalendarOffset: CGPoint? {
        didSet {
            print(#function, #line, "캘린더 시작 위치 : \(startCalendarOffset?.x ?? 0)" )
        }
    }
    
    @objc private func handleScopeGesture(_ gesture: UIPanGestureRecognizer) {
        print(#function, #line)
        let velocity = self.scopeGesture.velocity(in: self.view)
        let translation = self.scopeGesture.translation(in: self.view)
        // 수직 스크롤 가속도가 수평 스크롤 가속도보다 높은지
        let isPanningVertically = abs(velocity.y) > abs(velocity.x)
        
        
        // 수직
//        let isVerticalDistance = abs(translation.y) > abs(translation.x)
        
        
        
        if reactor!.currentState.scope == .month {

            // isPanningVertically로 수직스크롤 여부를 판단
            // !isHorizonGesture 는 대각선으로 스크롤 시 Y값이 높아지는 순간을 방지하기 위해서 (보험 이미 수평 스크롤이라면 수직 스크롤을 막음)
            // isVerticalGesture 는 대각선으로 스크롤 시 X값이 높아지는 순간을 방지하기 위해서 (보험, 이미 수직 스크롤이라면 수평 스크롤 로직을 막음)
            if isVerticalGesture || !isHorizonGesture && isPanningVertically {
                print(#function, #line, "#5 gestrue state : \(gesture.state)" )
                if !isVerticalGesture {
                    isVerticalGesture = true
                }
                self.handleMonthToWeekTransition(gesture: gesture)
                if gesture.state == .ended {
                    isVerticalGesture = false
                    print(#function, #line, "#7 세로 스크롤 끝" )
                }
                
            } else {
                guard !isVerticalGesture else { return }
                print(#function, #line, "#5 gestrue state : \(gesture.state)" )
                let currentOffset = self.calendarView.calendar.collectionView.contentOffset
                
                if !isHorizonGesture {
                    isHorizonGesture = true
                    startCalendarOffset = currentOffset
                }
                
                let destinationsOffset = CGPoint(x: currentOffset.x - translation.x, y: currentOffset.y)
                self.calendarView.calendar.collectionView.contentOffset = destinationsOffset
                print(#function, #line, "#7 가로 스크롤 진행중 : \(destinationsOffset.x)" )
                scopeGesture.setTranslation(.zero, in: self.view)
                if gesture.state == .ended {
                    let calendar = self.calendarView.calendar.collectionView!
                    let startOffsetX = startCalendarOffset?.x ?? 0
                    let thresholdDistance = calendar.bounds.width * 0.5
                    let distanceX = currentOffset.x - (startOffsetX)
                    let velocityX = scopeGesture.velocity(in: self.view).x
                    print(#function, #line, "#9 캘린더 너비: \(calendar.bounds.width)" )
                    print(#function, #line, "#9 이동거리 : \(distanceX), thresholde: \(thresholdDistance)" )
                    print(#function, #line, "#9 가속도 : \(velocityX)" )
                    if abs(distanceX) >= thresholdDistance || abs(velocityX) > VelocityThreshold.thresholdVelocity {
                        let paging: CalendarViewController.pageChangeType = startOffsetX < currentOffset.x ? .next : .previous
                        gsetrueTestScopeObserver.onNext(paging)
                        print(#function, #line, "#9 페이징 처리" )
                    } else {
                        print(#function, #line, "#9 : 원래페이지로 돌아가" )
                        guard let startCalendarOffset else { return }
                        self.calendarView.calendar.collectionView.setContentOffset(startCalendarOffset, animated: true)
                    }
                    
                    isHorizonGesture = false
//                    else {
//                        guard abs(velocityX) > VelocityThreshold.thresholdVelocity else { return }
//                        if velocityX > 0 {
//                            print(#function, #line, "#9 가속도로 인한 이전 페이징" )
//                        } else {
//                            print(#function, #line, "#9 가속도로 인한 다음 페이징" )
//                        }
//                    }
                    // 이동거리가 뷰의 반을 넘었다면 FS캘린더 내부로직으로 뷰를 넘겨줌 (자체적으로 page 셋팅해야함)
                    // 이동거리가 반이 넘지 않았을 땐 가속도를 체크해서 0이상이면 자체적으로 뷰를 넘겨줌 (셋팅 필요 X)
                }
                
                // 캘린더
                //
                //
                //                    // 제스처로 인한 스크롤이 끝난 지점
                //
                //
                //                    // 캘린더 가로 사이즈
                //
                //
                //                    // 이동거리 파악
                //
                //
                //
                //                    print(#function, #line, "currentOffsetX : \(currentOffsetX), calendarWidth : \(calendarWidth), distanceX : \(distanceX), threshHold: \(thresholde)" )
                //
                //                    if abs(distanceX) > halfWidth {
                //                        self.calendarView.handlePageChange(.current)
                //                        if distanceX > 0 {
                //
                //                        }
                //                    }
                
                
                
            }
        } else {
            switch gesture.state {
            case .ended:
                self.handleWeekToMonthTransition(translation.x)
            default: break
            }
        }
    }
    
    private func handleMonthToWeekTransition(gesture: UIPanGestureRecognizer) {
        self.scopeObserver.onNext(())
        self.gestureObserver.onNext(gesture)
    }
    
    private func handleWeekToMonthTransition(_ distance: Double) {
        guard distance > DistanceThreshold.weekToMonthDistance else { return }
        testScopeObserver.onNext(())
    }
    
    private func setGesture() {
        self.view.addGestureRecognizer(scopeGesture)
        self.scheduleListTableView.panGestureRequire(scopeGesture)
    }
    
}

extension CalendarScheduleViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /// 제스처 시작지점이 캘린더의 밖이거나 수직 제스처라면 true
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let currentScope = reactor!.currentState.scope
        
        guard !checkGestureLocationInCalendar() || !checkHorizonGesture() else { return false }
        return currentScope == .month ? true : checkHorizonGesture()
    }
    
    /// 제스처 시작 지점이 캘린더에 있는지 체크
    private func checkGestureLocationInCalendar() -> Bool {
        let gestureLoaction = scopeGesture.location(in: self.view)
        return calendarContainer.frame.contains(gestureLoaction)
    }

    /// 수평으로 제스처를 했는지 체크
    private func checkHorizonGesture() -> Bool {
        let velocity = self.scopeGesture.velocity(in: self.view)
        return abs(velocity.x) > abs(velocity.y)
    }
}

// MARK: - Date Picker
extension CalendarScheduleViewController {
    private func presentDatePicker() {
        let datePickView = YearMonthPickerViewController(reactor: reactor!)
        
        datePickView.modalPresentationStyle = .pageSheet
        
        if let sheet = datePickView.sheetPresentationController {
            sheet.detents = [ .medium() ]
        }
        
        self.present(datePickView, animated: true)
    }
}

// MARK: - UI Update
extension CalendarScheduleViewController {
    private func updateCalendarView(_ height: CGFloat) {
        print(#function, #line, "height : \(height)" )
        UIView.animate(withDuration: 0.33) {
            self.calendarContainer.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateMainView(_ scope: ScopeType) {
        print(#function, #line)
        UIView.animate(withDuration: 0.33) {
            self.updateHeaderView(scope: scope)
            self.updateBackgroundColor(scope: scope)
            self.naviItemChange(scope: scope)
            self.hideScheduleListTableView(scope: scope)
        }
    }
    
    private func updateHeaderView(scope: ScopeType) {
        let height = scope == .month ? 56 : 0
        
        self.headerButton.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    private func hideScheduleListTableView(scope: ScopeType) {
        scheduleListTableView.remakeConstraints(isHide: scope == .month)
    }
    
    #warning("참고")
    // 애니메이션 중에는 유저 액션이 차단되는데 이를 허용할 수 있는 옵션이 존재
    private func updateBackgroundColor(scope: ScopeType) {
        let views: [UIView] = [self.calendarContainer, self.scheduleListContainer, self.borderView]
        
        views.forEach {
            let color = scope == .month ? ColorStyle.Default.white : ColorStyle.BG.primary
            $0.backgroundColor = color
        }
    }
    
    private func naviItemChange(scope: ScopeType) {
        let isScopeMonth = scope == .month
        
        self.hideBaritem(type: .right, isHidden: !isScopeMonth)
        self.hideBaritem(type: .left, isHidden: isScopeMonth)
    }
    
    private func setHeaderLabel(date: DateComponents) {
        let year = date.year ?? 2024
        let monty = date.month ?? 1
        header.text = "\(year)년 \(monty)월"
    }
}

// MARK: - Home View에서 넘어왔을 때의 액션
extension CalendarScheduleViewController {
    
    /// 표시할 데이터가 있는 상태 : 홈뷰에서 표시한 이벤트 갯수 넘기기
    public func presentEvent(on lastRecentDate: Date) {
        self.presentEventObserver.accept(lastRecentDate)
    }
    
    /// 표시할 데이터가 없는 상태 : 로딩이 끝난 후 presentNextEvent count 다시 보내주기
    private func checkIsPresent(_ isLoading: Bool) {
        guard !isLoading,
              let recentEventCount = presentEventObserver.value else { return }
        presentEventObserver.accept(recentEventCount)
    }
    
    /// 화면을 벗어날 때 설정값 지우기
    private func resetPresentDate() {
        guard presentEventObserver.value == nil else { return }
        presentEventObserver.accept(nil)
    }
}





