//
//  PhotoManager.swift
//  Group
//
//  Created by CatSlave on 8/24/24.
//

import Foundation
import UIKit
import PhotosUI
import RxSwift
import RxCocoa

protocol PhotoService {
    func presentImagePicker() -> Single<[UIImage]>
    func updatePhotoLimit(_ limit: Int)
}

final class DefaultPhotoService: NSObject, PhotoService, UIAdaptivePresentationControllerDelegate  {

    private var pickerView: PHPickerViewController?
    
    private let alertManager = AlertManager.shared
    
    private var imageObserver: ((SingleEvent<[UIImage]>) -> Void)?
    
    private var limit: Int = 1
    
    public func presentImagePicker() -> Single<[UIImage]> {
        return Single.create { [weak self] emitter in
            guard let self else { return Disposables.create() }
            requestPhotoLibraryPermission()
            self.imageObserver = emitter
            return Disposables.create()
        }
    }
    
    public func updatePhotoLimit(_ limit: Int) {
        self.limit = limit
    }
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                switch status {
                case .authorized, .limited:
                    self?.configureImagePicker()
                case .denied, .restricted:
                    self?.imageObserver?(.success([]))
                    self?.showAppSettingAlert()
                default:
                    self?.imageObserver?(.success([]))
                }
            }
        }
    }
    
    private func showAppSettingAlert() {
        
        let defaultAction: DefaultAlertAction = .init(text: L10n.cancle,
                                                      textColor: .gray01,
                                                      bgColor: .appTertiary)
        
        let appSettingAction: DefaultAlertAction = .init(text: L10n.setup,
                                                         textColor: .defaultWhite,
                                                         bgColor: .appPrimary,
                                                         completion: {
            AppSettingOpener.openAppSettings()
        })
        
        alertManager.showWarningAlert(title: L10n.Photo.permissionInfo,
                                      subTitle: L10n.Photo.permissionSubinfo,
                                      defaultAction: defaultAction,
                                      addAction: [appSettingAction])
    }
    
    private func configureImagePicker() {
        guard let topView = UIApplication.shared.topVC else { return}
        var configuration = PHPickerConfiguration()
        configuration.selection = .ordered
        configuration.selectionLimit = limit
        configuration.filter = .images
        pickerView = PHPickerViewController(configuration: configuration)
        pickerView?.presentationController?.delegate = self
        guard let pickerView else { return }
        pickerView.delegate = self
        topView.present(pickerView, animated: true)
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.imageObserver?(.success([]))
    }
}

extension DefaultPhotoService: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let group = DispatchGroup()
        var imageList: [UIImage] = []
        var order: [Int] = []
        var asyncDict: [Int: UIImage] = [:]
        
        results.enumerated().forEach { index, result in
            order.append(index)
            group.enter()
            convertToUIImage(result.itemProvider) { image in
                DispatchQueue.main.async {
                    asyncDict[index] = image
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            for index in order {
                guard let image = asyncDict[index] else { continue }
                imageList.append(image)
            }
            
            self?.imageObserver?(.success(imageList))
            picker.dismiss(animated: true)
        }
    }
    
    private func convertToUIImage(_ provider: NSItemProvider, completion: @escaping (UIImage?) -> Void) {
        guard provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { image, error in
            completion(image as? UIImage)
        }
    }
}


