//
//  TabBarButton.swift
//  STPR
//
//  Created by Artur Chabera on 28/08/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class TabBarButton: UIButton {
    enum ButtonStyle {
        case standard, central
    }

    var color: UIColor = UIColor.lightGray {
        didSet {
            iconLabel.textColor = color
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                iconLabel.textColor = .mainFont
                textLabel.textColor = .mainFont
                if buttonStyle == .central {
                    backgroundColor = .mainFont
                    iconImageView.image = UIImage(named: "cameraActive")
                }
            } else {
                iconLabel.textColor = .tetrialyFont
                textLabel.textColor = .tetrialyFont
                if buttonStyle == .central {
                    backgroundColor = .mainFont
                    iconImageView.image = UIImage(named: "camera")
                    backgroundColor = .tetrialyFont
                }
            }
        }
    }
    
    private let iconLabel: UILabel = UILabel()
    private let textLabel: UILabel = UILabel()
    private let iconImageView: UIImageView = UIImageView()
    let buttonStyle: ButtonStyle
    private let icon: UIFont.Icon?
    private let text: String?
    
    init(icon: UIFont.Icon?, style: ButtonStyle, text: String?) {
        self.icon = icon
        self.buttonStyle = style
        self.text = text
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        switch buttonStyle {
        case .standard:
            guard
                let icon = icon,
                let text = text
                else { fatalError("You have to set icon") }
            backgroundColor = .clear
            addSubview(iconLabel)
            iconLabel.font = UIFont.iconFont(ofSize: 18)
            iconLabel.text = icon.rawValue
            iconLabel.textColor = .tetrialyFont
            iconLabel.textAlignment = .center
            iconLabel.isUserInteractionEnabled = false
            iconLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                iconLabel.leftAnchor.constraint(equalTo: leftAnchor),
                iconLabel.rightAnchor.constraint(equalTo: rightAnchor)
                ])

            textLabel.text = text
            textLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            textLabel.textColor = .tetrialyFont
            textLabel.textAlignment = .center
            addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 6),
                textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
                textLabel.leftAnchor.constraint(equalTo: leftAnchor),
                textLabel.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        case .central:
            let iconMargin: CGFloat = 12
            backgroundColor = .mainFont
            layer.borderWidth = 3.0
            layer.borderColor = UIColor.appBackground.cgColor
            addSubview(iconImageView)
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: iconMargin),
                iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -iconMargin),
                iconImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: iconMargin),
                iconImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -iconMargin)
            ])
            iconImageView.image = UIImage(named: "camera")
            clipsToBounds = true
        }
    }
}
