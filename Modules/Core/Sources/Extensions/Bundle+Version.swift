//
//  Bundle+Version.swift
//  Group
//
//  Created by CatSlave on 10/15/24.
//

import Foundation

extension Bundle {
    
    /// 버전 정보
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
