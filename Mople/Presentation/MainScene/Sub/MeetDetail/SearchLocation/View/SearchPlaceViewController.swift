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
    
    // MARK: - Reactor
    typealias Reactor = SearchPlaceViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private(set) var startView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setImage(image: .searchEmpty)
        view.setTitle(text: L10n.Searchplace.title)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private(set) var emptyView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setImage(image: .searchEmpty)
        view.setTitle(text: L10n.Searchplace.empty)
        view.isHidden = true
        view.isUserInteractionEnabled = false
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
        
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         reactor: SearchPlaceViewReactor?) {
        super.init(screenName: screenName)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissGestrue()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setSearchbar()
    }
    
    private func setLayout() {
        self.view.addSubview(startView)
        self.view.addSubview(emptyView)
        self.view.addSubview(placeListContainer)
        self.view.addSubview(detailPlaceContainer)
        
        [startView, emptyView].forEach {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
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
    
    private func setSearchbar() {
        self.searchBar.setInputPlaceHolder(text: L10n.Searchplace.input)
    }
}

// MARK: - Reactor Setup
extension SearchPlaceViewController {
    func bind(reactor: SearchPlaceViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }

    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
                vc.reactor?.action.onNext(.updateUserLocation)
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        [searchBar.rx.searchEvent, searchBar.rx.searchButtonEvent].forEach {
            $0.map { Reactor.Action.searchPlace(query: $0) }
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
            .map({ Reactor.Action.flow(.endProcess) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchBar.rx.isEditMode
            .filter { [weak self] isEdit in
                guard let self else { return false }
                let isActiveDetailView = !self.detailPlaceContainer.isHidden
                return isActiveDetailView && isEdit
            }
            .map({ _ in Reactor.Action.flow(.endProcess)})
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { vc, err in
                vc.alertManager.showDefatulErrorMessage()
            })
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

