//
//  TextField.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/9/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

final class CustomTextField: UIView {
    let textField = UITextField()
    private let errorLabel = UILabel()

    var text: String? {
        get {
            return textField.text
        }

        set {
            textField.text = newValue
        }
    }

    var placeholder: String? {
        didSet {
            textField.attributedPlaceholder = placeholder.map {
                NSAttributedString(
                    string: $0,
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainFont]
                )
            }
        }
    }

    var errorMessage: String? {
        didSet {
            errorLabel.text = errorMessage
            errorLabel.isHidden = errorMessage == nil
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
        backgroundColor = .appBackground

        errorLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        errorLabel.textColor = .tetrialyFont
        errorLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [textField, errorLabel])
        stack.directionalLayoutMargins = .init(top: 4, leading: 8, bottom: 4, trailing: 8)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0

        addSubview(stack)
        stack.fit(to: self)
    }

    func configureTextField(_ configure: (UITextField) -> Void) {
        configure(textField)
    }
}
