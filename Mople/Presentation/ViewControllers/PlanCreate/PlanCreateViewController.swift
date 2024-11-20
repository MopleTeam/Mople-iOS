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
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let groupSelectView: TitleButton = {
        let btn = TitleButton(title: TextStyle.CreatePlan.group,
                              inputText: TextStyle.CreatePlan.groupInfo)
        btn.setLayoutMargins()
        return btn
    }()
    
    private let planInputView: TitleTextField = {
        let view = TitleTextField(title: TextStyle.CreatePlan.plan,
                                  placeholder: TextStyle.CreatePlan.planInfo,
                                  maxCount: 30)
        view.setLayoutMargins()
        return view
    }()
    
    private let dateSelectView: TitleButton = {
        let btn = TitleButton(title: TextStyle.CreatePlan.date,
                              inputText: TextStyle.CreatePlan.dateInfo,
                              icon: .createCalendar)
        btn.setLayoutMargins()
        return btn
    }()
    
    private let timeSelectView: TitleButton = {
        let btn = TitleButton(title: TextStyle.CreatePlan.time,
                              inputText: TextStyle.CreatePlan.timeInfo,
                              icon: .createCalendar)
        btn.setLayoutMargins()
        return btn
    }()
    
    private let placeSelectView: TitleButton = {
        let btn = TitleButton(title: TextStyle.CreatePlan.plan,
                              inputText: TextStyle.CreatePlan.planInfo,
                              icon: .createPlace)
        btn.setLayoutMargins()
        return btn
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private let completeButton: CompletionButton = {
        let button = CompletionButton()
        button.setTitle(TextStyle.CreatePlan.completedTitle, for: .normal)
        return button
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            groupSelectView, planInputView, dateSelectView, timeSelectView, placeSelectView, emptyView
        ])
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
}

