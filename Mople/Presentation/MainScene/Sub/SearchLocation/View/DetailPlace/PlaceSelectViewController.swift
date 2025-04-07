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
    
    typealias Reactor = SearchPlaceViewReactor
    
    var disposeBag = DisposeBag()
    
    private let placeInfo: PlaceInfo
        
    private let mapView = MapInfoView(type: .select)
    
    init(reactor: SearchPlaceViewReactor?,
         place: PlaceInfo) {
        self.placeInfo = place
        super.init()
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }

    private func initalSetup() {
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

    func bind(reactor: SearchPlaceViewReactor) {
        self.mapView.selectedButton.rx.controlEvent(.touchUpInside)
            .compactMap { [weak self] _ in
                guard let self else { return nil }
                return Reactor.Action.completed(place: placeInfo)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}


