//
//  NotifyViewModel.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import Foundation

struct NotifyViewModel {
    let thumbnailPath: String?
    let title: String?
    var subTitle: String?
}

extension NotifyViewModel {
    init(notify: Notify) {
        self.thumbnailPath = notify.meetImgPath
        self.title = notify.payload?.message
        setSubTitle(with: notify)
    }
    
    private mutating func setSubTitle(with notify: Notify) {
        guard let meetTitle = notify.meetTitle,
              let timeDescription = notify.postDate?.timeAgoDescription() else { return }
        subTitle = meetTitle + " · " + timeDescription
    }
}
