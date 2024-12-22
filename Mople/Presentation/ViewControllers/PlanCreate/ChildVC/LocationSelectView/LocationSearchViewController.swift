//
//  LocationSearchViewController.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class LocationSearchViewController: SearchNaviViewController, View {
    typealias Reactor = PlanCreateViewReactor
    
    var disposeBag = DisposeBag()
    
    private let emptyView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setImage(image: .searchEmpty)
        view.setTitle(text: "약속 장소를 검색해주세요")
        return view
    }()
    
    init(reactor: PlanCreateViewReactor) {
        super.init()
        self.reactor = reactor
        setPresentationStyle()

    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()

    }
    
    private func initialSetup() {
        setupUI()
        setupAction()
    }
    
    // MARK: - ModalStyle
    private func setPresentationStyle() {
        modalPresentationStyle = .fullScreen
    }
    
    private func setupUI() {
        self.view.addSubview(emptyView)
        
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func bind(reactor: PlanCreateViewReactor) {
        
    }
    
    // MARK: - Action
    private func setupAction() {
        self.backTapEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    }
}
