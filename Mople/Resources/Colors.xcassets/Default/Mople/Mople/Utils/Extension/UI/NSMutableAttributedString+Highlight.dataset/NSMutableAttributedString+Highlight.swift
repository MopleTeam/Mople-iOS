//
//  NSMutableAttributedString+Ext.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import UIKit

extension NSMutableAttributedString {
    static func makeHighlightText(fullText: String,
                                 fullTextFont: UIFont = FontStyle.Body1.medium,
                                  fullTextColor: UIColor = .gray04,
                                 highlightText: String,
                                 highlightFont: UIFont = FontStyle.Body1.medium,
                                  highlightColor: UIColor = .appPrimary) -> NSMutableAttributedString {
        
        let fullTextAttributed = getAttributedString(text: fullText,
                                                   font: fullTextFont,
                                                   color: fullTextColor)
        setHighlightText(attributedString: fullTextAttributed,
                         text: highlightText,
                         font: highlightFont,
                         color: highlightColor)
        
        return fullTextAttributed
    }
    
    private static func getAttributedString(text: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(.textAttributes(font: font,
                                                       color: color),
                                       range: .init(location: 0, length: text.count))
        return attributedString
    }
    
    private static func setHighlightText(attributedString: NSMutableAttributedString,
                                         text: String,
                                         font: UIFont,
                                         color: UIColor) {
        guard let range = attributedString.string.range(of: text) else { return }
        attributedString.addAttributes(.textAttributes(font: font,
                                                       color: color),
                                       range: .init(range, in: attributedString.string))
    }
}

extension [NSAttributedString.Key: Any] {
    static func textAttributes(font: UIFont,
                               color: UIColor) -> Self {
        return [
            .font: font,
            .foregroundColor: color
        ]
    }
}
