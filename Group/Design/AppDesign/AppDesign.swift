//
//  AppColor.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit

typealias ItemConfigure = (text: String?, font: UIFont?, color: UIColor?, image: UIImage?)

protocol UIConstructive {
    var itemConfig: ItemConfigure { get }
}

extension UIConstructive {
    var itemConfig: ItemConfigure { ItemConfigure(text: nil, font: nil, color: nil, image: nil) }
    
    func makeUIConfigure(text: String? = nil,
                         font: UIFont? = nil,
                         color: UIColor? = nil,
                         image: UIImage? = nil) -> ItemConfigure {
        return (text, font, color, image)
    }
}

struct AppDesign {
    
    static let mainBackColor = UIColor(hexCode: "F5F5F5")
    static let defaultBlack = UIColor(hexCode: "222222")
    static let defaultWihte = UIColor(hexCode: "FFFFFF")
    static let defaultBlue = UIColor(hexCode: "3366FF")
    static let defaultGray = UIColor(hexCode: "666666")
}

// MARK: - App Design
extension AppDesign {
    
   
    
    enum TabBar {
        static let titleFont = FontStyle.Body3.semiBold
        static let titleColor = UIColor.init(hexCode: "999999")
        static let normalColor = UIColor.init(hexCode: "E1E3E5")
        static let selectedColor = UIColor.init(hexCode: "3E3F40")
    }
    
    enum Layer {
        static let lineColor = UIColor(hexCode: "F2F2F2")
        static let shadowColor = AppDesign.defaultBlack
    }
}

// MARK: - Home Flow Design


// MARK: - Schedule


// MARK: - Weather


// MARK: - GroupList Flow Design


// MARK: - Calendar Flow Design







