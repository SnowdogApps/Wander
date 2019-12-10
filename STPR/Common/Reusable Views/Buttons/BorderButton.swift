//
//  BorderButton.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/7/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

final class BorderButton: UIButton {
    override init(frame: CGRect) {
         super.init(frame: frame)
         setupLookAndFeel()
     }

     required init?(coder: NSCoder) {
         super.init(coder: coder)
         setupLookAndFeel()
     }

     private func setupLookAndFeel() {
        setTitleColor(.mainFont, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: .headline)
        layer.borderColor = UIColor.mainFont.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 16
     }
}
