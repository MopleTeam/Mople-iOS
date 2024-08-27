//
//  PhotoManager.swift
//  Group
//
//  Created by CatSlave on 8/24/24.
//

import Foundation
import UIKit
import PhotosUI

protocol PhotoService {
    typealias Delegate = UIViewController & PHPickerViewControllerDelegate
    
    func requestPhotoLibraryPermission(delegate: Delegate)
}

final class PhotoManager: PhotoService {
    
    private var delegate: Delegate?
    
    func requestPhotoLibraryPermission(delegate: Delegate) {
        self.delegate = delegate
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    print("사진 라이브러리 접근 권한이 허용되었습니다.")
                    self.configureImagePicker()
                case .denied, .restricted:
                    print("사진 라이브러리 접근 권한이 거부되었습니다.")
                    // 사용자에게 설정에서 권한을 허용하도록 안내합니다.
                case .notDetermined:
                    print("사진 라이브러리 접근 권한이 아직 결정되지 않았습니다.")
                @unknown default:
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
        pickerViewController.delegate = delegate
        delegate?.present(pickerViewController, animated: true)
    }
}
