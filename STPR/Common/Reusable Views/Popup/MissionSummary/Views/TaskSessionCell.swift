//
//  TaskSessionCell.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/14/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

final class TaskSessionCell: UITableViewCell {
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var iconLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subheadLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    var viewModel: TaskSessionViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            titleLabel.text = viewModel.title
            subheadLabel.text = viewModel.subtitle
            iconLabel.textColor = viewModel.isCompleted ? .appGreen : .tetrialyFont
            dateLabel.text = viewModel.completedData
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.layer.cornerRadius = 8
        cardView.layer.masksToBounds = false
        cardView.backgroundColor = .containerBackground
        contentView.backgroundColor = .appBackground

        titleLabel.textColor = .mainFont
        subheadLabel.textColor = .secondaryFont
        dateLabel.textColor = .tetrialyFont
        iconLabel.font = UIFont.iconFont(ofSize: 20)
        iconLabel.text = UIFont.Icon.check.rawValue
    }
}

extension TaskSessionCell: NibReusableView {}
