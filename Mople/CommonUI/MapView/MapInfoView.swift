//
//  DefaultMapView.swift
//  Mople
//
//  Created by CatSlave on 1/3/25.
//

import UIKit
import SnapKit

final class MapInfoView: UIView {
    
    private let place: PlaceInfo
    
    private let mapView = MapView(isScroll: true)
    
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
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.regular
        label.textColor = ColorStyle.Gray._05
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private(set) lazy var selectedButton: BaseButton = {
        let button = BaseButton()
        button.setTitle(text: "장소 선택",
                        font: FontStyle.Title3.semiBold,
                        normalColor: ColorStyle.Default.white)
        button.setBgColor(normalColor: ColorStyle.App.primary)
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
        setMapView()
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
        addressLabel.text = place.roadAddress
        setDistanceLabel()
    }
    
    private func setDistanceLabel() {
        guard let distance = place.distance else { return }
        
        switch distance {
        case 1..<1000:
            distanceLabel.text = "\(distance)m"
        case 1000...:
            let kilometers = Double(distance) / 1000
            let rounded = round(kilometers * 10) / 10
            let roundedDistance = Int(rounded)
            distanceLabel.text = "\(roundedDistance)km"
        default:
            distanceLabel.isHidden = true
            break
        }
    }
    
    private func setMapView() {
        mapView.initializeMap(location: place.location ?? .defaultLocation,
                              offset: .init(x: 0, y: -(mainStackView.bounds.height / 2)))
    }
}
