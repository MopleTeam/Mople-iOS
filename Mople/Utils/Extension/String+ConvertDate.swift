//
//  String+ConvertDate.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

extension String {
    func convertDate() -> Date? {
        DateManager.isoFormatter.date(from: self)
    }
}


