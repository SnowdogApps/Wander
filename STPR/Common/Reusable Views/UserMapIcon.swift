//
//  UserMapIcon.swift
//  STPR
//
//  Created by Artur Chabera on 07/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class UserMapIcon: UIView {

    private var iconLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        iconLabel = UILabel(frame: CGRect(
                x: frame.width / 4, y: frame.height / 4,
                width: frame.width / 2, height: frame.height / 2
            ))
        iconLabel.font = UIFont.iconFont(ofSize: 12)
        iconLabel.text = UIFont.Icon.arrow.rawValue
        iconLabel.textColor = .appGreen
        iconLabel.textAlignment = .center
        addSubview(iconLabel)
        iconLabel.backgroundColor = .appBackground
        iconLabel.layer.cornerRadius = frame.width / 4
        iconLabel.clipsToBounds = true

        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
        backgroundColor = UIColor.appGreen.withAlphaComponent(0.4)
    }
}
