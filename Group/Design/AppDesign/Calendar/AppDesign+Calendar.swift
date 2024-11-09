//
//  AppDesign+Calendar.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    
    enum Calendar: UIConstructive {
        
        static let headerColor: UIColor = .init(hexCode: "FAFAFA")
        static let weekTextColor: UIColor = .init(hexCode: "999999")
        static let dayFont: UIFont = FontStyle.Title3.semiBold
        static let weekFont: UIFont = FontStyle.Body1.medium
        static let eventTextColor: UIColor = AppDesign.defaultBlack
        static let dayTextColor: UIColor = .init(hexCode: "DDDDDD")
        static let selectedDayTextColor: UIColor = AppDesign.defaultBlue
    }
}
