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

final class DefaultPhotoService: PhotoService {

    private var pickerView: PHPickerViewController?
    
    private var imageObserver: ((SingleEvent<[UIImage]>) -> Void)?
    
    private var limit: Int
    
    init(limit: Int = 1) {
        self.limit = limit
    }
    
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
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self.configureImagePicker()
                case .denied, .restricted:
                    //
                    print("사진 라이브러리 접근 권한이 거부되었습니다.")
                default:
                    break
                }
            }
        }
    }
    
    private func configureImagePicker() {
        guard let topView = UIApplication.shared.topVC else { return}
        var configuration = PHPickerConfiguration()
        configuration.selection = .ordered
        configuration.selectionLimit = limit
        configuration.filter = .images
        pickerView = PHPickerViewController(configuration: configuration)
        guard let pickerView else { return }
        pickerView.delegate = self
        topView.present(pickerView, animated: true)
    }
}

extension DefaultPhotoService: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print(#function, #line)
                
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


