//
//  DefaultMapView.swift
//  Mople
//
//  Created by CatSlave on 1/3/25.
//

import UIKit
import NMapsMap

final class DefaultMapView: UIView {
    
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
    
    private(set) lazy var selectedButton: BaseButton = {
        let button = BaseButton()
        button.setTitle(text: "장소 선택",
                        font: FontStyle.Title3.semiBold,
                        normalColor: ColorStyle.Default.white)
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
    
    init(place: PlaceInfo) {
        print(#function, #line, "LifeCycle Test DetailPlaceViewController Created" )
        self.place = place
        super.init(frame: .zero)
        self.initalSetup()
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DetailPlaceViewController Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.initializeMap()
    }
    
    private func initalSetup() {
        setLayout()
        setLabel()
    }
    
    private func setLayout() {
        self.addSubview(mapView)
        self.addSubview(mainStackView)
        
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
}

// MARK: - Setup Map
extension DefaultMapView {
    private func initializeMap() {
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
