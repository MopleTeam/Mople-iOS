//
//  DefaultMapView.swift
//  Mople
//
//  Created by CatSlave on 1/3/25.
//

import UIKit
import SnapKit

struct MapInfoViewModel {
    let title: String?
    let address: String?
    let location: Location?
    private let distance: Int?
    
    var distanceText: String? {
        guard let distance = distance else { return nil }
        
        switch distance {
        case 1..<1000:
            return "\(distance)m"
        case 1000...:
            let kilometers = Double(distance) / 1000
            let rounded = round(kilometers * 10) / 10
            let roundedDistance = Int(rounded)
            return "\(roundedDistance)km"
        default:
            return nil
        }
    }
}

extension MapInfoViewModel {
    init(place: PlaceInfo) {
        self.title = place.title
        self.address = place.roadAddress
        self.location = place.location
        self.distance = place.distance
    }
}

final class MapInfoView: UIView {
    
    enum ViewType {
        case basic
        case select
    }
        
    private var location: Location?
    
    private let mapView = MapView(isScroll: true,
                                  isZoom: true)
    
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
        let sv = UIStackView(arrangedSubviews: [placeInfoStackView])
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
    
    init(type: ViewType = .basic) {
        print(#function, #line, "LifeCycle Test DetailPlaceViewController Created" )
        super.init(frame: .zero)
        initalSetup(type)
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
    
    private func initalSetup(_ type: ViewType) {
        setTypeConfigure(type)
        setLayout()
    }
    
    private func setTypeConfigure(_ type: ViewType) {
        guard case .select = type else { return }
        mainStackView.addArrangedSubview(selectedButton)
        
        selectedButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
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
    }
    
    private func setMapView() {
        mapView.initializeMap(location: location ?? .defaultLocation,
                              offset: .init(x: 0, y: -(mainStackView.bounds.height / 2)))
    }
    
    public func setConfigure(_ viewModel: MapInfoViewModel) {
        self.location = viewModel.location
        titleLable.text = viewModel.title
        addressLabel.text = viewModel.address
        setDistanceLabel(distanceText: viewModel.distanceText)
    }
    
    private func setDistanceLabel(distanceText: String?) {
        if let distanceText {
            distanceLabel.text = distanceText
        } else {
            distanceLabel.isHidden = true
        }
    }
}
