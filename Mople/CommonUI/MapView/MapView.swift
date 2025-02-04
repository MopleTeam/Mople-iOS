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
    
    private func setLayout() {
        self.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setMapView(isScroll: Bool, isZoom: Bool) {
        self.mapView.isScrollGestureEnabled = isScroll
        self.mapView.isZoomGestureEnabled = isZoom
        self.mapView.gestureRecognizers?.forEach({ $0.delegate = self })
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
                              offset: CGPoint = .init(x: 0, y: 0)) {
        guard let lat = location.latitude,
              let lng = location.longitude else { return }
        let position = NMGLatLng(lat: lat, lng: lng)
        self.moveMap(position: position)
        self.addMarker(position: position)
        self.centerMapWithUIOffset(offset) 
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
