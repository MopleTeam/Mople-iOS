//
//  PlanCreateViewController.swift
//  Mople
//
//  Created by CatSlave on 11/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

// 모임 생성 뷰 : (리액터 포함) 홈화면에서는 모임 리스트가 있지만, 모임 상세에서는 없음 최신화를 위해서 API 요청 -> 모임 ID
// 날짜 선택 뷰 : (리액터 포함) 일정 날짜
// 시간 선택 뷰 : (리액터 포함) 일정 시간 (오늘이면 5분 뒤 부터 설정가능, 미래면 모든 시간)
// 맵 뷰 : (리액터 포함) 일정 장소
// 현재 뷰 : 일정 이름
// 요청 시 : 액션 처리 (탭: 그룹 리스트, 화면 모임상세 -> 일정 상세)

final class PlanCreateViewController: DefaultViewController, View {
    
    typealias Reactor = PlanCreateViewReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    
    private let contentView = UIView()
    
    private let groupSelectButton: LabeledButton = {
        let btn = LabeledButton(title: TextStyle.CreatePlan.group,
                              inputText: TextStyle.CreatePlan.groupInfo)
        return btn
    }()
    
    private let planTitleTextField: LabeledTextField = {
        let view = LabeledTextField(title: TextStyle.CreatePlan.plan,
                                  placeholder: TextStyle.CreatePlan.planInfo,
                                  maxCount: 30)
        return view
    }()
        
    private let dateSelectButton: LabeledButton = {
        let btn = LabeledButton(title: TextStyle.CreatePlan.date,
                              inputText: TextStyle.CreatePlan.dateInfo,
                              icon: .createCalendar)
        btn.layer.zPosition = 1
        return btn
    }()
        
    private let timeSelectButton: LabeledButton = {
        let btn = LabeledButton(title: TextStyle.CreatePlan.time,
                              inputText: TextStyle.CreatePlan.timeInfo,
                              icon: .createCalendar)
        return btn
    }()
    
    private let placeSelectButton: LabeledButton = {
        let btn = LabeledButton(title: TextStyle.CreatePlan.plan,
                              inputText: TextStyle.CreatePlan.planInfo,
                              icon: .createPlace)
        return btn
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private let completeButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.CreatePlan.completedTitle,
                     font: FontStyle.Title3.semiBold,
                     color: ColorStyle.Default.white)
        btn.setBgColor(ColorStyle.App.primary, disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(8)
        btn.rx.isEnabled.onNext(false)
        return btn
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            groupSelectButton, planTitleTextField, dateSelectButton,
            timeSelectButton, placeSelectButton, emptyView
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()
    
    // MARK: - Gesture
    private let backTapGesture = UITapGestureRecognizer()
    
    // MARK: - LifeCycle
    init(title: String?, reactor: PlanCreateViewReactor) {
        print(#function, #line, "LifeCycle Test PlanCreateView Created" )
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PlanCreateView Deinit" )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNaviItem()
        setButtonAction()
        setGeestureBind()
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(completeButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            make.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide.snp.height)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(completeButton.snp.top)
        }
        
        completeButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(mainStackView)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().inset(UIScreen.getBottomSafeAreaHeight())
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left, image: .arrowBack)
    }
    
    // 날짜 이름만 리액터에 연결, 모임 id, 날짜, 시간, 장소는 각 뷰에서 넘겨줘야 함
    // 추가로 받을 것 모든 데이터 입력됐을 시 completed버튼 활성화
    func bind(reactor: PlanCreateViewReactor) {
        planTitleTextField.rx_editing
            .compactMap { [weak self] _ in self?.planTitleTextField.text }
            .map({ Reactor.Action.setPlanName(name: $0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$seletedMeet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0?.name }
            .drive(groupSelectButton.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedDay)
            .asDriver(onErrorJustReturn: nil)
            .map({
                DateManager.toString(date: $0?.toDate(), format: .simple)
            })
            .drive(dateSelectButton.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedTime)
            .asDriver(onErrorJustReturn: nil)
            .map({
                DateManager.toString(date: $0?.toDate(), format: .time)
            })
            .drive(timeSelectButton.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setButtonAction() {
        leftItemEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.dateSelectButton.rx_tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                self.presentSubView(destination: .date)
            })
            .disposed(by: disposeBag)
        
        self.groupSelectButton.rx_tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                self.presentSubView(destination: .group)
            })
            .disposed(by: disposeBag)
        
        self.timeSelectButton.rx_tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                self.presentSubView(destination: .time)
            })
            .disposed(by: disposeBag)
    }
    
    private func setGeestureBind() {
        backTapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(backTapGesture)
        backTapGesture.rx.event
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}

extension PlanCreateViewController {
    enum Route {
        case group
        case date
        case time
    }
    
    private func presentSubView(destination: Route) {
        let destinationVC: UIViewController
        
        switch destination {
        case .group:
            destinationVC = GroupSelectViewController(reactor: reactor!)
        case .date:
            destinationVC = PlanDateSelectViewController(reactor: reactor!)
        case .time:
            destinationVC = PlanTimePickerViewController(reactor: reactor!)
        }
        
        self.present(destinationVC, animated: true)
    }
}



