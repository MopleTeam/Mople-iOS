//
//  AppSettingOpener.swift
//  Mople
//
//  Created by CatSlave on 4/15/25.
//

import UIKit

enum AppSettingOpener {
    static func openAppSettings(completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url,
                                  options: [:],
                                  completionHandler: completion)
    }
}
