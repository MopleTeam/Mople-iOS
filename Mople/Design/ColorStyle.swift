//
//  ColorStyle.swift
//  Group
//
//  Created by CatSlave on 11/11/24.
//

import UIKit

struct ColorStyle {
    
    enum App {
        static let primary: UIColor = .init(hexCode: "3366FF")
        static let secondary: UIColor = .init(hexCode: "3E3F40")
        static let tertiary: UIColor = .init(hexCode: "F1F2F3")
        static let icon: UIColor = .init(hexCode: "D9D9D9")
        static let stroke: UIColor = .init(hexCode: "F2F2F2")
    }
    
    enum Default {
        static let black: UIColor = .init(hexCode: "000000")
        static let white: UIColor = .init(hexCode: "FFFFFF")
        static let red: UIColor = .init(hexCode: "FF3B30")
        static let blueGray: UIColor = .init(hexCode: "EBF0FF")
        static let green: UIColor = .init(hexCode: "34C759")
        static let yellow: UIColor = .init(hexCode: "FEE500")
        static let blue: UIColor = .init(hexCode: "668CFF")
    }

    enum BG {
        static let primary: UIColor = .init(hexCode: "F5F5F5")
        static let secondary: UIColor = .init(hexCode: "F7F7F8")
        static let input: UIColor = .init(hexCode: "F6F8FA")
    }
    
    enum Primary {
        static let disable: UIColor = .init(hexCode: "D6E0FF")
        static let disable2: UIColor = App.secondary.withAlphaComponent(0.3)
    }
    
    enum Input {
        static let icon: UIColor = .init(hexCode: "DEE0E3")
        static let disable: UIColor = .init(hexCode: "E2E5E9")
    }
    
    enum Gray {
        static let _01: UIColor = .init(hexCode: "222222")
        static let _02: UIColor = .init(hexCode: "333333")
        static let _03: UIColor = .init(hexCode: "555555")
        static let _04: UIColor = .init(hexCode: "888888")
        static let _05: UIColor = .init(hexCode: "999999")
        static let _06: UIColor = .init(hexCode: "CCCCCC")
        static let _07: UIColor = .init(hexCode: "DCDCDC")
    }
}



