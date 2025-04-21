//
//  String+UrlEncode.swift
//  Mople
//
//  Created by CatSlave on 4/18/25.
//

import Foundation

extension String {
    
    /// URL 쿼리에  안전하게 넣을 수 있도록 인코딩 처리
    func urlEncoded() -> String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
