//
//  DetailPlaceViewController.swift
//  Mople
//
//  Created by CatSlave on 1/2/25.
//

import UIKit
import NMapsMap
import ReactorKit
import RxSwift

final class PlaceSelectViewController: BaseViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = SearchPlaceViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private let placeInfo: PlaceInfo
        
    // MARK: - UI Components
    private let mapView: MapInfoView = {
        let view = MapInfoView()
        view.setSelectButton(text: L10n.Searchplace.selected,
                             textFont: FontStyle.Title3.semiBold,
                             textColor: .defaultWhite,
                             backColor: .appPrimary)
        return view
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         reactor: SearchPlaceViewReactor?,
         place: PlaceInfo) {
        self.placeInfo = place
        super.init(screenName: screenName)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.setConfigure(.init(place: placeInfo))
    }

    // MARK: - UI Setup
    private func setupUI() {
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Reactor Setup
    func bind(reactor: SearchPlaceViewReactor) {
        self.mapView.rx.selected
            .compactMap { [weak self] _ in
                guard let self else { return nil }
                return Reactor.Action.flow(.completed(place: placeInfo))
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}


