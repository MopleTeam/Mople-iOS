//
//  LocationService.swift
//  Mople
//
//  Created by CatSlave on 1/10/25.
//

import Foundation
import RxSwift
import CoreLocation

protocol LocationService {
    func updateLocation() -> Observable<CLLocationCoordinate2D?>
}
final class DefaultLocationService: NSObject, CLLocationManagerDelegate, LocationService {
    
    let locationManager = CLLocationManager()
    
    private let locationSubject = PublishSubject<CLLocationCoordinate2D?>()

    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer 
    }
    
    private func requestPremission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
}

extension DefaultLocationService {
    func updateLocation() -> Observable<CLLocationCoordinate2D?> {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            requestPremission()
        default:
            break
        }
        
        return self.locationSubject.asObservable()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.onNext(locations.first?.coordinate)
        locationSubject.onCompleted()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.onNext(nil)
        print("Location error: \(error.localizedDescription)")
    }
}
