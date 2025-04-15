//
//  DefaultMapView.swift
//  Mople
//
//  Created by CatSlave on 1/3/25.
//

import UIKit
import RxSwift
import RxCocoa
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
 
    // MARK: - Variables
    private var location: Location?
    
    // MARK: - UI Components
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
    
    fileprivate lazy var selectedButton: BaseButton = {
        let button = BaseButton()
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
        sv.layoutMargins = .init(top: 20,
                                 left: 20,
                                 bottom: UIScreen.getSafeBottomHeight(),
                                 right: 20)
        sv.backgroundColor = ColorStyle.Default.white
        sv.layer.makeCornes(radius: 20, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        sv.layer.makeShadow(opactity: 0.1,
                            radius: 8)
        return sv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    deinit {
        print(#function, #line, "LifeCycle Test DetailPlaceViewController Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        print(#function, #line)
        self.setMapView()
    }
    
    private func setupUI() {
        self.addSubview(mapView)
        self.addSubview(mainStackView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        selectedButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    private func setMapView() {
        print(#function, #line)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            mapView.initializeMap(location: location ?? .defaultLocation,
                                  offset: .init(x: 0, y: -(mainStackView.bounds.height / 2)))
        }
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
    
    public func setSelectButton(text: String?,
                                textFont: UIFont?,
                                textColor: UIColor?,
                                backColor: UIColor?) {
        selectedButton.setTitle(text: text,
                                font: textFont,
                                normalColor: textColor)
        selectedButton.setBgColor(normalColor: backColor)
    }
}

extension Reactive where Base: MapInfoView {
    var selected: ControlEvent<Void> {
        return base.selectedButton.rx.tap
    }
}


