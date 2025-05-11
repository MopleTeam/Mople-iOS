//
//  PlaceDetailViewController.swift
//  Mople
//
//  Created by CatSlave on 2/3/25.
//

import UIKit
import RxSwift
import ReactorKit

final class PlaceDetailViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = PlaceDetailViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Variables
    private var placeInfo: PlaceInfo?
    
    // MARK: - UI Components
    private let mapView: MapInfoView = {
        let view = MapInfoView()
        view.setSelectButton(text: L10n.Placedetail.findLoad,
                             textFont: FontStyle.Title3.semiBold,
                             textColor: .gray01,
                             backColor: .appTertiary)
        return view
    }()

    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: PlaceDetailViewReactor) {
        super.init(screenName: screenName,
                   title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setNavi()
    }
    
    private func setLayout() {
        self.view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left, image: .backArrow)
    }
}

// MARK: - Reactor Setup
extension PlaceDetailViewController {
    func bind(reactor: PlaceDetailViewReactor) {
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
            })
            .disposed(by: disposeBag)
    }
    
    private func setActionBind(_ reactor: Reactor) {
        naviBar.leftItemEvent
            .map({ Reactor.Action.endProcess })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        mapView.rx.selected
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.presentSelectMapView()
            })
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$placeInfo)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, placeInfo in
                vc.mapView.setConfigure(.init(place: placeInfo))
                vc.placeInfo = placeInfo
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, err in
                vc.alertManager.showDefatulErrorMessage()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Select Map Service
extension PlaceDetailViewController {
    private func presentSelectMapView() {
        guard let placeLat =  placeInfo?.location?.latitude,
              let placeLon = placeInfo?.location?.longitude else { return }
        
        let naverMapAction: DefaultSheetAction = .init(text: L10n.Placedetail.mapNaver,
                                                       image: .naverMap,
                                                       completion: { [weak self] in
            self?.openNaverMap(lat: placeLat,
                               lon: placeLon,
                               placeTitle: self?.placeInfo?.title)
        })
        
        let kakaoMapAction: DefaultSheetAction = .init(text: L10n.Placedetail.mapKakao,
                                                       image: .kakaoMap,
                                                       completion: { [weak self] in
            self?.openKakaoMap(lat: placeLat,
                               lon: placeLon)
        })
        
        sheetManager.showSheet(actions: [naverMapAction, kakaoMapAction])
    }
    
    private func openNaverMap(lat: Double, lon: Double, placeTitle: String?) {
        let bundleId = AppConfiguration.bundleID
        guard let placeTitle,
              let endcodeTitle = placeTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let mapURL = URL(string: "nmap://route?dlat=\(lat)&dlng=\(lon)&dname=\(endcodeTitle)&appname=\(bundleId)"),
              let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8") else { return }
        
        openMap(mapURL: mapURL,
                appStoreURL: appStoreURL)
    }
    
    private func openKakaoMap(lat: Double, lon: Double) {
        guard let mapURL = URL(string: "kakaomap://look?p=\(lat),\(lon)"),
              let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id304608425") else { return }
        
        openMap(mapURL: mapURL,
                appStoreURL: appStoreURL)
    }
    
    private func openMap(mapURL: URL, appStoreURL: URL) {
        if UIApplication.shared.canOpenURL(mapURL) {
            UIApplication.shared.open(mapURL)
        } else {
            UIApplication.shared.open(appStoreURL)
        }
    }
}


