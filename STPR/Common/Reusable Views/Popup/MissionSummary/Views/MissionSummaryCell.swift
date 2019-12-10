//
//  MissionSummaryCell.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/14/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

final class MissionSummaryCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var headlineLabel: UILabel!

    var modelController: MissionSessionModelController? {
        didSet {
            guard let modelController = modelController else {
                return
            }
            bodyLabel.text = String(format: "congrats".localized(), modelController.title)

            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: UIColor.mainFont,
            ]

            let points = NSMutableAttributedString(
                string: String(modelController.totalXP),
                attributes: attributes
            )

            let total = NSMutableAttributedString(string: "totalEarned".localized())
            total.append(points)
            
            captionLabel.attributedText = total
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "super".localized()
        titleLabel.textColor = .mainFont

        bodyLabel.textColor = .secondaryFont
        captionLabel.textColor = .tetrialyFont
        separator.backgroundColor = .containerBackground

        headlineLabel.textColor = .mainFont
        headlineLabel.text = "missionSummary".localized()

        contentView.backgroundColor = .appBackground
    }
}

extension MissionSummaryCell: NibReusableView {}
