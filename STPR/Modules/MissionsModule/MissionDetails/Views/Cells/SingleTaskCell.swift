//
//  SingleTaskCell.swift
//  STPR
//
//  Created by Artur Chabera on 18/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class SingleTaskCell: ReusableCollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    var viewModel: SingleTaskViewModel! {
        didSet {
            bindViewModel()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconLabel.text = nil
    }

    private func setupUI() {
        containerView.backgroundColor = .containerBackground
        containerView.layer.cornerRadius = 10.0

        titleLabel.textColor = .mainFont
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        subtitleLabel.textColor = .secondaryFont
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    private func bindViewModel() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.description
        iconLabel.font = UIFont.iconFont(ofSize: 30)

        switch viewModel.state {
        case .available:
            iconLabel.text = viewModel.taskType.icon.rawValue
            iconLabel.textColor = .appYellow
        case .finished:
            iconLabel.text = UIFont.Icon.check.rawValue
            iconLabel.textColor = .appGreen
        case .failed:
            iconLabel.text = UIFont.Icon.check.rawValue
            iconLabel.textColor = .tetrialyFont
        }
    }
}
