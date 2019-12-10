//
//  MissionCell.swift
//  STPR
//
//  Created by Artur Chabera on 16/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

final class MissionCell: ReusableCollectionViewCell {
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var playerAvatarsContainer: UIView!
    @IBOutlet weak var containerView: UIView!

    var missionModel: SingleMissionViewModel! {
        didSet {
            setupCell()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconLabel.isHidden = true
        backgroundImageView.alpha = 1
        backgroundImageView.image = nil
        playerAvatarsContainer.subviews.forEach { $0.removeFromSuperview() }
    }

    private func setupUI() {
        containerView.layer.cornerRadius = 10.0
        containerView.clipsToBounds = true
        containerView.backgroundColor = .containerBackground

        timeLabel.textColor = .tetrialyFont
        timeLabel.text = "time".localized()

        distanceLabel.textColor = .tetrialyFont
        distanceLabel.text = "distance".localized()
        cityLabel.textColor = .secondaryFont

        iconLabel.font = UIFont.iconFont(ofSize: 30)
        iconLabel.text = UIFont.Icon.check.rawValue
        iconLabel.textColor = .appGreen
        iconLabel.layer.shadowColor = UIColor.black.cgColor
        iconLabel.layer.shadowOffset = .init(width: 1, height: 1)
        iconLabel.layer.shadowOpacity = 1
    }

    private func setupCell() {
        if let image = missionModel.backgroundUrl {
            if missionModel.isCompleted {
                backgroundImageView.setImage(
                    from: image,
                    options: [
                        .cacheOriginalImage,
                        .processor(BlackWhiteColorFilter())
                    ]
                )
            } else {
                backgroundImageView.setImage(from: image)
            }
        }

        timeValueLabel.text = missionModel.time
        distanceValueLabel.text = missionModel.distanceFormatted
        titleLabel.text = missionModel.title
        descriptionLabel.text = missionModel.missionDescription
        cityLabel.text = missionModel.city

        iconLabel.isHidden = !missionModel.isCompleted
        /// addPlayerAvatars()
    }

    /**
     Method for adding avatars to cell
     We are waiting for full implementation of user sessions
     Avatar is container where UIImage with user avatar will be added
     Optionally - if there is more than 3, last avartar is label with number of players
     */
    private func addPlayerAvatars() {
        let itemsFromAPI = 3
        let numberOfItems = min(itemsFromAPI, 3)

        for i in 0 ..< numberOfItems {
            let width: CGFloat = 32.0

            let avatar = UIView()
            avatar.translatesAutoresizingMaskIntoConstraints = false
            avatar.layer.cornerRadius = width / 2
            avatar.clipsToBounds = true
            avatar.layer.borderColor = UIColor.containerBackground.cgColor
            avatar.layer.borderWidth = 1.0
            avatar.backgroundColor = .secondaryFont

            let modifier = CGFloat(numberOfItems - 1) * (width / 2)
            let leftConstraint = width - modifier + CGFloat(i) * (width / 2)

            playerAvatarsContainer.addSubview(avatar)
            NSLayoutConstraint.activate([
                avatar.leftAnchor.constraint(
                    equalTo: playerAvatarsContainer.leftAnchor, constant: leftConstraint
                ),
                avatar.heightAnchor.constraint(equalToConstant: width),
                avatar.widthAnchor.constraint(equalToConstant: width)
            ])
        }
    }
}
