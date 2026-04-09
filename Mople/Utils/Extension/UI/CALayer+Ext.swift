//
//  CALayer+Line.swift
//  Group
//
//  Created by CatSlave on 10/3/24.
//

import UIKit

extension CALayer {
    func makeLine(width: CGFloat, color: UIColor = .appStroke) {
        self.borderWidth = width
        self.borderColor = color.cgColor
    }

    func makeCornes(radius: CGFloat, corners: CACornerMask) {
        self.cornerRadius = radius
        self.maskedCorners = corners
    }

    func makeShadow(opactity: Float,
                    radius: CGFloat,
                    offset: CGSize = .init(width: 0, height: -4),
                    color: UIColor = UIColor.black) {
        self.shadowOpacity = opactity
        self.shadowRadius = radius
        self.shadowOffset = offset
        self.shadowColor = color.cgColor
    }
}

// MARK: - 다크/라이트 모드 대응 Border 설정
// CGColor는 정적 값이라 모드 전환 시 자동 업데이트가 안 됨
// UIView의 registerForTraitChanges로 모드 전환 시 borderColor를 재적용
extension UIView {
    func setDynamicBorder(width: CGFloat, color: UIColor = .appStroke) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: UIView, _) in
            view.layer.borderColor = color.cgColor
        }
    }
}
