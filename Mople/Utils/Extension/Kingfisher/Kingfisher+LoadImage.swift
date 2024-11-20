//
//  Kingfisher+LoadImage.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    #warning("현재 기본 사진이 유저로 표시되어 있음, 모델, 히스토리 용, 날씨 필요")
    func kfSetimage(_ path: String?) -> DownloadTask? {
        guard let path = path,
              let url = URL(string: path) else { return nil }
        self.kf.indicatorType = .activity
        
        return self.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "questionmark.square.fill"),
            options: [.transition(.fade(0.2))]
        )
    }
}

