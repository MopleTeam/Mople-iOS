//
//  AppDesign+Weather.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    
    enum Weather: UIConstructive {
        static let backColor = UIColor.init(hexCode: "F6F7FA")
        
        case temperature
        case city
        
        var itemConfig: ItemConfigure {
            switch self {
            case .temperature:
                return makeUIConfigure(font: FontStyle.Body1.semiBold,
                                       color: ColorStyle.Gray._01)
            case .city:
                return makeUIConfigure(font: FontStyle.Body2.medium,
                                       color: .init(hexCode: "888888"))
            }
        }
    }
}
