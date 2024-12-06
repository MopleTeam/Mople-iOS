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
        
    private let dateSelectView: LabeledButton = {
        let btn = LabeledButton(title: TextStyle.CreatePlan.date,
                              inputText: TextStyle.CreatePlan.dateInfo,
                              icon: .createCalendar)
        btn.layer.zPosition = 1
        return btn
    }()
        
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
            groupSelectView, planInputView, dateSelectView,
            timeSelectView, placeSelectView, emptyView
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()
    
    // MARK: - Gesture
    private let backTapGesture = UITapGestureRecognizer()
    
    // MARK: - LifeCycle
    override init(title: String?) {
        print(#function, #line, "LifeCycle Test PlanCreateView Created" )
        super.init(title: title)
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
    
    private func setButtonAction() {
        leftItemEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.dateSelectView.rx_tap
            .subscribe(with: self, onNext: { vc, isHide in
                let datePickerView = FullDatePickerViewController()
                
                datePickerView.modalPresentationStyle = .pageSheet
                
                if let sheet = datePickerView.sheetPresentationController {
                    sheet.detents = [ .medium() ]
                }
                self.present(datePickerView, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.timeSelectView.rx_tap
            .subscribe(with: self, onNext: { vc, isHide in
                
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



