//
//  Kingfisher+LoadImage.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    func kfSetimage(_ path: String?) -> DownloadTask? {
        guard let path = path,
              let url = URL(string: path) else { return nil }
        
        return self.kf.setImage(
            with: url,
            placeholder: AppDesign.Profile.defaultImage,
            options: [.transition(.fade(0.2))]
        )
    }
}

