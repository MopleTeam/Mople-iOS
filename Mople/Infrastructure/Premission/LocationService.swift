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
    func updateLocation() -> Observable<Location?>
}
final class DefaultLocationService: NSObject, CLLocationManagerDelegate, LocationService {
    
    private let locationManager = CLLocationManager()
    private let savedLocation = UserInfoStorage.shared.userInfo?.location
    private let locationSubject = PublishSubject<Location?>()
    private let authorizationSubject = PublishSubject<Void>()
    

    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    private func requestLocationWithTimeout() -> Observable<Location?> {
        return self.locationSubject.asObservable()
            .do(onSubscribed: { [weak self] in
                self?.locationManager.requestLocation()
            })
            .timeout(.seconds(1), scheduler: MainScheduler.instance)
            .catchAndReturn(savedLocation)
    }
    
    private func requestPremission() -> Observable<Location?> {
        return self.authorizationSubject
            .do(onSubscribed: { [weak self] in
                self?.locationManager.requestWhenInUseAuthorization()
            })
            .flatMap { [weak self] _ -> Observable<Location?> in
                guard let self else { return .empty() }
                return self.requestLocationWithTimeout()
            }
    }
}

extension DefaultLocationService {
    func updateLocation() -> Observable<Location?> {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            return requestLocationWithTimeout()
        case .notDetermined:
            return requestPremission()
        default:
            return .empty()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first?.coordinate else {
            locationSubject.onCompleted()
            return
        }
        let location: Location = .init(longitude: userLocation.longitude,
                                       latitude: userLocation.latitude)
        updateUserLocation(location)
        locationSubject.onNext(location)
        locationSubject.onCompleted()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationSubject.onNext(())
            authorizationSubject.onCompleted()
        case .notDetermined:
            break
        default:
            authorizationSubject.onCompleted()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.onNext(savedLocation)
        locationSubject.onCompleted()
    }
    
    private func updateUserLocation(_ location: Location) {
        UserInfoStorage.shared.updateLocation(location)
    }
}
