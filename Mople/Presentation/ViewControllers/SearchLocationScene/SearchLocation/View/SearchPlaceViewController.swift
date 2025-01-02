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

// PlanCreate Reactor를 받아와서 데이터 공유하기
class SearchPlaceViewController: SearchNaviViewController, View {
    typealias Reactor = SearchPlaceReactor
    
    var disposeBag = DisposeBag()
    
    private(set) var startView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setImage(image: .searchEmpty)
        view.setTitle(text: "약속 장소를 검색해주세요")
        view.backgroundColor = ColorStyle.Default.blue
        return view
    }()
    
    private(set) var emptyView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setImage(image: .apple)
        view.setTitle(text: "검색결과 없음")
        view.isHidden = true
        view.backgroundColor = ColorStyle.Default.red
        return view
    }()
    
    private(set) var placeListContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private(set) var detailPlaceContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
        
    init(reactor: SearchPlaceReactor?) {
        print(#function, #line, "LifeCycle Test SearchLocationViewController Created" )
        super.init()
        self.reactor = reactor
        setPresentationStyle()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SearchLocationViewController Deinit" )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupKeyboardDismissGestrue()
    }
    
    private func initialSetup() {
        setupUI()
        setupKeyboardDismissGestrue()
    }
    
    // MARK: - ModalStyle
    private func setPresentationStyle() {
        modalPresentationStyle = .fullScreen
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.addSubview(startView)
        self.view.addSubview(emptyView)
        self.view.addSubview(placeListContainer)
        self.view.addSubview(detailPlaceContainer)
        
        [startView, emptyView].forEach {
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.lessThanOrEqualTo(self.view)
            }
        } 
        
        [placeListContainer, detailPlaceContainer].forEach {
            $0.snp.makeConstraints { make in
                make.top.equalTo(self.searchViewBottom)
                make.horizontalEdges.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
    }
    
    func bind(reactor: SearchPlaceReactor) {
        [searchBar.rx.searchEvent, searchBar.rx.searchButtonEvent].forEach { $0.map { [weak self] _ in
            return Reactor.Action.searchPlace(query: self?.searchQuery)
        }
        .bind(to: reactor.action)
        .disposed(by: disposeBag) }
        
        searchBar.rx.editEvent
            .filter({ [weak self] in
                guard let count = self?.searchQuery?.count else { return true }
                return count == 0
            })
            .map({ Reactor.Action.fetchCahcedPlace })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchBar.rx.backEvent
            .map({ Reactor.Action.endProcess })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
}

extension SearchPlaceViewController: KeyboardDismissable, UIGestureRecognizerDelegate {
    var tapGestureShouldCancelTouchesInView: Bool { false }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupKeyboardDismissGestrue() {
        setupPanKeyboardDismiss()
        setupTapKeyboardDismiss()
    }
}

