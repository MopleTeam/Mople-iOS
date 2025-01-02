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

final class DetailPlaceViewController: UIViewController, View {
    
    typealias Reactor = SearchPlaceReactor
    
    var disposeBag = DisposeBag()
    
    private let place: PlaceInfo
    
    private let mapView = NMFMapView()
    
    private let titleLable: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._02
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.semiBold
        label.textColor = ColorStyle.Gray._02
        label.textAlignment = .left
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.regular
        label.textColor = ColorStyle.Gray._05
        label.textAlignment = .left
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let selectedButton: BaseButton = {
        let button = BaseButton()
        button.setTitle(text: "장소 선택",
                        font: FontStyle.Title3.semiBold,
                        color: ColorStyle.Default.white)
        button.setBgColor(ColorStyle.App.primary)
        button.setRadius(8)
        return button
    }()
    
    private lazy var locationStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [distanceLabel, addressLabel])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var placeInfoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLable, locationStackView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [placeInfoStackView, selectedButton])
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 0, right: 20)
        sv.backgroundColor = ColorStyle.Default.white
        sv.layer.makeCornes(radius: 20, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        sv.layer.makeShadow(opactity: 0.1,
                            radius: 8)
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initializeMap(place: place)
    }
    
    init(reactor: SearchPlaceReactor?,
         place: PlaceInfo) {
        print(#function, #line, "LifeCycle Test DetailPlaceViewController Created" )
        self.place = place
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DetailPlaceViewController Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        setLayout()
        setLabel()
    }
    
    private func setLayout() {
        self.view.addSubview(mapView)
        self.view.addSubview(mainStackView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        selectedButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    private func setLabel() {
        titleLable.text = place.title ?? "이름없음"
        addressLabel.text = place.address
        setDistanceLabel(place.distance)
    }
    
    private func setDistanceLabel(_ distance: Int?) {
        guard let distance else { return }
        distanceLabel.text = "\(distance)m"
    }
    
    func bind(reactor: SearchPlaceReactor) {
        selectedButton.rx.controlEvent(.touchUpInside)
            .compactMap { [weak self] in
                guard let self else { return nil }
                return Reactor.Action.selectedPlace(self.place)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - Setup Map
extension DetailPlaceViewController {
    private func initializeMap(place: PlaceInfo) {
        guard let lat = place.latitude,
              let lng = place.longitude else { return }
        let position = NMGLatLng(lat: lat, lng: lng)
        self.moveMap(position: position)
        self.centerMapWithUIOffset()
        self.addMarker(position: position)
    }
    
    private func moveMap(position: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate.init(scrollTo: position, zoomTo: 17)
        mapView.moveCamera(cameraUpdate)
    }
    
    private func centerMapWithUIOffset() {
        let moveUp = NMFCameraUpdate.init(scrollBy: .init(x: 0, y: -(mainStackView.bounds.height / 2)))
        mapView.moveCamera(moveUp)
    }
    
    private func addMarker(position: NMGLatLng) {
        let marker = NMFMarker(position: position)
        marker.iconImage = .init(image: .selectedLocation)
        marker.mapView = mapView
    }
}
