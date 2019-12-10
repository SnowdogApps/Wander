//
//  BlackButton.swift
//  STPR
//
//  Created by Majid Jabrayilov on 8/30/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

final class FilledButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .appGreen : .darkGray
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLookAndFeel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLookAndFeel()
    }

    private func setupLookAndFeel() {
        layer.cornerRadius = 20
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: .headline)
        backgroundColor = .appGreen
    }
}
