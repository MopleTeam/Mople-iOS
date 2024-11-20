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


final class PhotoManager {
   
    var delegate: UIViewController
    var imageObserver: AnyObserver<UIImage?>
    
    init(delegate: UIViewController,
         imageObserver: AnyObserver<UIImage?>) {
        self.delegate = delegate
        self.imageObserver = imageObserver
    }
    
    public func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    print("사진 라이브러리 접근 권한이 허용되었습니다.")
                    self.configureImagePicker()
                case .denied, .restricted:
                    print("사진 라이브러리 접근 권한이 거부되었습니다.")
                default:
                    break
                }
            }
        }
    }
    
    private func configureImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        delegate.present(pickerViewController, animated: true)
    }
}

// MARK: - Photos
extension PhotoManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemprovider = results.first?.itemProvider,
              itemprovider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemprovider.loadObject(ofClass: UIImage.self) { [weak self] image , error  in
            if let error = error {
                print("사진선택 오류 발생")
            }
            guard let self = self,
                  let image = image as? UIImage else { return }
            self.imageObserver.onNext(image)
        }
    }
}
