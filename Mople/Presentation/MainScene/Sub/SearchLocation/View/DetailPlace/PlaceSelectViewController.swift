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
        
    private let mapView = MapInfoView(type: .select)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    init(reactor: SearchPlaceViewReactor?) {
        super.init()
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func bind(reactor: SearchPlaceViewReactor) {
        self.mapView.selectedButton.rx.controlEvent(.touchUpInside)
            .map { Reactor.Action.completed }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedPlace)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, place in
                vc.mapView.setConfigure(.init(place: place))
            })
            .disposed(by: disposeBag)
    }
}


