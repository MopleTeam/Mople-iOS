//
//  Bundle+Version.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import Foundation

#warning("버전 정보 가져오기")
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
