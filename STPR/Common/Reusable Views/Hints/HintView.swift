//
//  HintView.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/27/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

final class HintView: UIView {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var trailingLabel: UILabel!
    @IBOutlet private weak var iconLabel: UILabel!

    var action: (() -> Void)?

    var icon: UIFont.Icon = .exclamation {
        didSet {
            iconLabel.text = icon.rawValue
        }
    }

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    var body: String = "" {
        didSet {
            bodyLabel.text = body
        }
    }

    var trailingText: String = "" {
        didSet {
            trailingLabel.text = trailingText
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        setupXib()

        iconLabel.textColor = .appYellow
        iconLabel.font = UIFont.iconFont(ofSize: 24)
        titleLabel.textColor = .mainFont
        bodyLabel.textColor = .secondaryFont
        trailingLabel.textColor = .tetrialyFont

        backgroundView.backgroundColor = .appBackground
        backgroundView.layer.shadowColor = UIColor.appBackground.cgColor
        backgroundView.layer.shadowOffset = .init(width: 1, height: 1)
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.masksToBounds = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hintTapped(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc private func hintTapped(_ sender: UIGestureRecognizer) {
        action?()
    }
}

extension HintView: NibLoadableView {}
