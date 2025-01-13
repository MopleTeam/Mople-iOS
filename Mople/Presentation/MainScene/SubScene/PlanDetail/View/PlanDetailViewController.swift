//
//  PlanDetailViewController.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import RxSwift
import ReactorKit

final class PlanDetailViewController: TitleNaviViewController, View {
    
    typealias Reactor = PlanDetailViewReactor
    
    var disposeBag = DisposeBag()
    
    private let planInfoView = PlanDetailInfoView()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.sectionFooterHeight = 8
        table.tableHeaderView = UIView(frame: .init(x: 0,
                                                    y: 0,
                                                    width: table.bounds.width,
                                                    height: 28))
        return table
    }()
    
    init(reactor: PlanDetailViewReactor, title: String?) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(planInfoView)
        initalSetup()
        setAction()
    }
    
    private func initalSetup() {
        setLayout()
        setNavi()
    }
    
    private func setLayout() {
        self.view.addSubview(planInfoView)
        
        planInfoView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.equalToSuperview()
        }
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left, image: .backArrow)
    }
    
    func bind(reactor: PlanDetailViewReactor) {
        reactor.pulse(\.$plan)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, plan in
                vc.planInfoView.configure(with: .init(plan))
            })
            .disposed(by: disposeBag)
            
    }
    
    private func setAction() {
        self.naviBar.leftItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    }
}
