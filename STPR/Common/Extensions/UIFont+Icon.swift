//
//  UIFont+Icon.swift
//  STPR
//
//  Created by Artur Chabera on 24/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

extension UIFont {
    enum Icon: String {
        case add = "\u{e903}"
        case collect = "\u{e900}"
        case run = "\u{e901}"
        case scan = "\u{e902}"
        case show = "\u{e904}"
        case arrow = "\u{e905}"
        case back = "\u{e906}"
        case calendar = "\u{e907}"
        case check = "\u{e908}"
        case chevronRight = "\u{e909}"
        case choose = "\u{e90a}"
        case city = "\u{e90b}"
        case coins = "\u{e90c}"
        case exclamation = "\u{e90d}"
        case gps = "\u{e90e}"
        case location = "\u{e90f}"
        case map = "\u{e910}"
        case medal = "\u{e911}"
        case menu = "\u{e912}"
        case missions = "\u{e913}"
        case profile = "\u{e914}"
        case question = "\u{e915}"
        case roundClose = "\u{e916}"
        case settings = "\u{e917}"
        case social = "\u{e918}"
        case star = "\u{e919}"
        case time = "\u{e91a}"
        case walk = "\u{e91b}"

        func image(color: UIColor, fontSize: CGFloat = 20, size: CGSize) -> UIImage {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = NSTextAlignment.center

            let attributedString = NSAttributedString(string: rawValue, attributes: [
                NSAttributedString.Key.font: UIFont.iconFont(ofSize: fontSize),
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.backgroundColor: UIColor.clear,
                NSAttributedString.Key.paragraphStyle: paragraph,
                NSAttributedString.Key.strokeWidth: 0,
                NSAttributedString.Key.strokeColor: UIColor.clear
                ])

            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let rect = CGRect(x: 0, y: 2, width: size.width, height: size.height)
            attributedString.draw(in: rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
    }

    class func iconFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "icomoon", size: ofSize)!
    }
}
