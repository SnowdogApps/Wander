//
//  NSAttributedString.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/9/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

extension NSAttributedString {
    static func underlined(_ text: String) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.foregroundColor: UIColor.mainFont,
            NSAttributedString.Key.underlineColor: UIColor.mainFont
        ]

        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: attributes
        )

        return attributedText
    }

    static func underline(_ underlined: String, in text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryFont]
        )

        text.range(of: underlined).map {
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.foregroundColor: UIColor.mainFont,
                NSAttributedString.Key.underlineColor: UIColor.mainFont
            ]

            attributedText.addAttributes(attributes, range: NSRange($0, in: text))
        }

        return attributedText
    }
}
