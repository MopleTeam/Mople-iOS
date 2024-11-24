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

final class PlanCreateViewController: DefaultViewController {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var datePickerHeightConstraint: Constraint?
    var timePickerHeightConstraint: Constraint?
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let groupSelectView: LabeledButton = {
        let btn = LabeledButton(title: TextStyle.CreatePlan.group,
                              inputText: TextStyle.CreatePlan.groupInfo)
        return btn
    }()
    
    private let planInputView: LabeledTextField = {
        let view = LabeledTextField(title: TextStyle.CreatePlan.plan,
                                  placeholder: TextStyle.CreatePlan.planInfo,
                                  maxCount: 30)
        return view
    }()
    
    private let dateContainerView = UIView()
    
    private let dateSelectView: LabeledButton = {
        let btn = LabeledButton(title: TextStyle.CreatePlan.date,
                              inputText: TextStyle.CreatePlan.dateInfo,
                              icon: .createCalendar)
        btn.layer.zPosition = 1
        return btn
    }()
    
    private let timeContainerView = UIView()
    
    private let timeSelectView: LabeledButton = {
        let btn = LabeledButton(title: TextStyle.CreatePlan.time,
                              inputText: TextStyle.CreatePlan.timeInfo,
                              icon: .createCalendar)
        return btn
    }()
    
    private let placeSelectView: LabeledButton = {
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
            groupSelectView, planInputView, dateContainerView,
            timeContainerView, placeSelectView, emptyView
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()
    
    // MARK: - Picker
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.minimumDate = DateManager.getMinimumDate()
        datePicker.maximumDate = DateManager.getMaximumDate()
        return datePicker
    }()
    
    private let timePicker = DefaultTimePickerView()
    
    // MARK: - Gesture
    private let backTapGesture = UITapGestureRecognizer()
    private let pickerTapGesture = UITapGestureRecognizer()

    private func setGeestureBind() {
        // 다른 이벤트와 같이 들어왔을 때 취소할건지
        // false : 허용한다.
        // 예외)
        // 텍스트필드의 키보드 리스폰은 터치 이벤트보다 우선 처리가 됨 (텍스트 필드의 키보드는 시스템 핸들링)
        // 버튼은 이벤트와 동급 처리 (버튼은 단순 터치 / 유저 핸들링)
        backTapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(backTapGesture)
        backTapGesture.rx.event
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - LifeCycle
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
        self.dateContainerView.addSubview(dateSelectView)
        self.dateContainerView.addSubview(datePicker)
        self.timeContainerView.addSubview(timeSelectView)
        self.timeContainerView.addSubview(timePicker)
        
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
        
        dateSelectView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(datePicker.snp.top).inset(1)
        }
        
        // datePicker의 높이를 1이상 주지 않으면 View에 처음 표시될 때 부적절한 애니메이션으로 표시
        datePicker.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            datePickerHeightConstraint = make.height.equalTo(1).constraint
        }
        
        timeSelectView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(timePicker.snp.top)
        }
        
        // datePicker의 높이를 1이상 주지 않으면 View에 처음 표시될 때 부적절한 애니메이션으로 표시
        timePicker.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0)
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
    
    private func setButtonAction() {
        leftItemEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.dateSelectView.rx_tap
            .scan(true, accumulator: { previous, _ in !previous })
            .subscribe(with: self, onNext: { vc, isHide in
                vc.hideDatePicker(isHide)
            })
            .disposed(by: disposeBag)
        
        self.timeSelectView.rx_tap
            .scan(false, accumulator: { previous, _ in !previous })
            .subscribe(with: self, onNext: { vc, isHide in
                UIView.animate(withDuration: 0.3) {
                    vc.timePicker.snp.updateConstraints { make in
                        make.height.equalTo(isHide ? vc.timePicker.defaultHeight : 0)
                    }
                    vc.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        self.datePicker.rx.date
            .subscribe(with: self, onNext: { vc, date in
                print(#function, #line, "date : \(date)" )
            })
            .disposed(by: disposeBag)
    }
    
    private func hideDatePicker(_ isHide: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.datePickerHeightConstraint?.isActive = isHide
            self.view.layoutIfNeeded()
        }
    }

    private func hideTimePicker(_ isHide: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.timePicker.snp.updateConstraints { make in
                make.height.equalTo(isHide ? 0 : self.timePicker.defaultHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    
}


final class DefaultTimePickerView: UIView {
    
    public var defaultHeight: CGFloat {
        return pickerView.sizeThatFits(.zero).height
    }
    
    private let hours: [Int] = Array(1...12)
    private let minutes: [Int] = Array(stride(from: 0, through: 55, by: 5))
    private let periods = ["오전", "오후"]
    private let nextHour: Int = (Date().getHours() % 12)
            
    private let pickerView = UIPickerView()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = FontStyle.Title2.semiBold
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
        setDatePicker()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.clipsToBounds = true
        self.addSubview(pickerView)
        
        pickerView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
        }
    }

    private func setDatePicker() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(nextHour, inComponent: 0, animated: false)
        pickerView.selectRow(0, inComponent: 1, animated: false)
    }
    
    private func dequeuePickerLabel(reusing view: UIView?) -> UILabel {
        return (view as? UILabel) ?? {
            let newLabel = UILabel()
            newLabel.textAlignment = .center
            newLabel.textColor = .black
            newLabel.font = FontStyle.Title2.semiBold
            return newLabel
        }()
    }
}



// MARK: - DatePicker
extension DefaultTimePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: hours.count
        case 1: minutes.count
        case 2: periods.count
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = self.dequeuePickerLabel(reusing: view)
        
        switch component {
        case 0: label.text = "\(hours[row]) 시"
        case 1: label.text = "\(minutes[row]) 분"
        case 2: label.text = periods[row]
        default: break
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
//        if component == 0 {
//            selectedDate.month = months[row]
//        } else {
//            selectedDate.year = years[row]
//        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

