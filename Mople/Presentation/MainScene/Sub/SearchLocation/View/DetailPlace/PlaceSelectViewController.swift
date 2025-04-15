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
    private var searchPlaceReactor: SearchPlaceViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private let placeInfo: PlaceInfo
        
    // MARK: - UI Components
    private let mapView: MapInfoView = {
        let view = MapInfoView()
        view.setSelectButton(text: "장소 선택",
                             textFont: FontStyle.Title3.semiBold,
                             textColor: ColorStyle.Default.white,
                             backColor: ColorStyle.App.primary)
        return view
    }()
    
    // MARK: - LifeCycle
    init(reactor: SearchPlaceViewReactor?,
         place: PlaceInfo) {
        self.placeInfo = place
        super.init()
        searchPlaceReactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setReactor()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setPlace()
    }
    
    private func setLayout() {
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setPlace() {
        mapView.setConfigure(.init(place: placeInfo))
    }
    
    // MARK: - Reactor Setup
    private func setReactor() {
        reactor = searchPlaceReactor
    }

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


