//
//  MapView.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//

import UIKit
import SnapKit
import NMapsMap

final class MapView: UIView {
        
    private let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.isIndoorMapEnabled = false  // 실내지도 사용 안 함
        mapView.buildingHeight = 0  // 3D 건물 표시 안 함
        mapView.isRotateGestureEnabled = false  // 회전 제스처 비활성화
        mapView.isTiltGestureEnabled = false  // 기울이기 제스처 비활성화
        
        // 줌 레벨 제한
        mapView.minZoomLevel = 14  // 줌아웃 제한 강화 (더 가깝게)
        mapView.maxZoomLevel = 19  // 줌인 범위 확대 (더 자세하게)
        return mapView
    }()
    
    private let addPlaceImage: UIImageView = {
        let view = UIImageView(image: .mapPlus)
        view.contentMode = .scaleToFill
        return view
    }()
    
    private let addPlaceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text04
        label.font = FontStyle.Body1.medium
        label.text = "장소를 추가해주세요"
        
        return label
    }()
    
    private lazy var addSv: UIStackView = {
        let view = UIStackView(arrangedSubviews: [addPlaceImage, addPlaceLabel])
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        view.distribution = .fill
        return view
    }()
    
    init(isScroll: Bool = false,
         isZoom: Bool = false) {
        super.init(frame: .zero)
        setLayout()
        setMapView(isScroll: isScroll,
                   isZoom: isZoom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print(#function, #line, "Path : # 테스트 ")
    }
    
    private func setLayout() {
        self.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setMapView(isScroll: Bool, isZoom: Bool) {
        self.mapView.isScrollGestureEnabled = isScroll
        self.mapView.isZoomGestureEnabled = isZoom
        self.mapView.gestureRecognizers?.forEach({
            $0.delegate = self
        })
    }
    
    public func setAddMapView() {
        mapView.isHidden = true
        self.addSubview(addSv)
        
        addSv.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        addPlaceImage.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
}

extension MapView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let isEdgeGesture = otherGestureRecognizer is UIScreenEdgePanGestureRecognizer
        return isEdgeGesture == false
    }
}

// MARK: - Setup Map
extension MapView {
    public func initializeMap(location: Location,
                              adjustOffset: CGPoint = .init(x: 0, y: 0)) {
        DispatchQueue.main.async { [weak self] in
            guard let lat = location.latitude,
                  let lng = location.longitude else { return }
            let position = NMGLatLng(lat: lat, lng: lng)
            self?.layoutIfMapViewEmpty()
            self?.addMarker(position: position)
            self?.moveMap(position: position)
            self?.centerMapWithUIOffset(adjustOffset)
        }
    }
    
    private func layoutIfMapViewEmpty() {
        guard mapView.frame.size == .zero else { return }
        layoutIfNeeded()
    }
    
    private func moveMap(position: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate.init(scrollTo: position, zoomTo: 17)
        mapView.moveCamera(cameraUpdate)
    }
    
    private func addMarker(position: NMGLatLng) {
        let marker = NMFMarker(position: position)
        marker.iconImage = .init(image: .selectedLocation)
        marker.mapView = mapView
    }
    
    private func centerMapWithUIOffset(_ offset: CGPoint) {
        let moveUp = NMFCameraUpdate.init(scrollBy: offset)
        mapView.moveCamera(moveUp)
    }
}
