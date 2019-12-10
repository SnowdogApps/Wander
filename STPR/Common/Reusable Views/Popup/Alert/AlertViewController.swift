//
//  AlertViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/11/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

final class AlertViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subheadLabel: UILabel!
    @IBOutlet private weak var textFieldStack: UIStackView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var actionsStack: UIStackView!

    private var textFieldsConfigurations: [(UITextField) -> Void] = []
    private let configuration: Configuration
    private let impactGenerator = UIImpactFeedbackGenerator(style: .soft)

    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLookAndFeel()
        impactGenerator.prepare()
    }

    func addTextField(_ configurator: @escaping (UITextField) -> Void) {
        textFieldsConfigurations.append(configurator)
    }

    var textFields: [CustomTextField] {
        textFieldStack.arrangedSubviews.compactMap { $0 as? CustomTextField }
    }

    private func setupLookAndFeel() {
        titleLabel.textColor = .mainFont
        titleLabel.text = configuration.title

        subheadLabel.textColor = .secondaryFont
        subheadLabel.text = configuration.subhead

        if let image = configuration.image {
            imageView.image = image
        } else {
            imageView.isHidden = true
        }

        textFieldsConfigurations.forEach {
            let textField = CustomTextField()
            textField.configureTextField($0)
            textFieldStack.addArrangedSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        }

        textFieldStack.isHidden = textFieldsConfigurations.isEmpty
        separator.isHidden = configuration.actions.isEmpty
        actionsStack.isHidden = configuration.actions.isEmpty

        configuration.actions.enumerated().forEach { index, action in
            let actionButton = action.style == .positive ? FilledButton() : BorderButton()
            actionButton.tag = index
            actionButton.setTitle(action.title, for: .normal)
            actionButton.addTarget(self, action: #selector(executeAction(sender:)), for: .touchUpInside)
            actionsStack.addArrangedSubview(actionButton)
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }

    @objc private func executeAction(sender: UIButton) {
        impactGenerator.impactOccurred()
        configuration.actions[sender.tag].handler(self)
        dismiss(animated: false, completion: nil)
    }
}

extension AlertViewController {
    struct Configuration {
        let image: UIImage?
        let title: String
        let subhead: String
        let actions: [Action]
    }

    struct Action {
        let title: String
        let style: Style
        let handler: (AlertViewController) -> Void

        enum Style {
            case positive
            case plain
        }
    }
}

extension AlertViewController {
    static func make(title: String, subhead: String = "", image: UIImage? = nil) -> AlertViewController {
        let configuration = Configuration(
            image: image,
            title: title,
            subhead: subhead,
            actions: [
                .init(title: "ok".localized(), style: .plain, handler: { _ in })
            ]
        )
        return AlertViewController(configuration: configuration)
    }

    static func makeResetPassword(_ handler: @escaping (String) -> Void) -> AlertViewController {
        let configuration = AlertViewController.Configuration(
            image: nil,
            title: "resetViaEmail".localized(),
            subhead: "",
            actions: [
                .init(title: "reset".localized(), style: .positive) {
                    handler($0.textFields.first?.text ?? "")
                }
            ]
        )
        let alert = AlertViewController(configuration: configuration)

        alert.addTextField {
            $0.placeholder = "email".localized()
            $0.textContentType = .emailAddress
            $0.keyboardType = .emailAddress
        }

        return alert
    }

    static func makeGalileoAlert() -> AlertViewController {
        let configuration = Configuration(
            image: UIImage(named: "sticker_galileo"),
            title: "galileoTitle".localized(),
            subhead: "galileoSubTitle".localized(),
            actions: [
                Action(
                    title: "continue".localized(),
                    style: .plain,
                    handler: { _ in }
                )
            ]
        )
        return AlertViewController(configuration: configuration)
    }

    static func makeSuccessAlert(for task: Task, completion: @escaping () -> Void) -> AlertViewController {
        let singleTaskVM = SingleTaskViewModel(task: task, session: nil)
        let configuration = Configuration(
            image: UIImage(named: "award"),
            title: "alertSuccess".localized(),
            subhead: singleTaskVM.completedMessage,
            actions: [
                Action(
                    title: "continue".localized(),
                    style: .positive,
                    handler: { _ in completion() }
                )
            ]
        )
        return AlertViewController(configuration: configuration)
    }

    static func makeErrorAlert(for error: Error, retry: @escaping () -> Void = {}) -> AlertViewController {
        let configuration = Configuration(
            image: UIImage(named: "error"),
            title: "oops".localized(),
            subhead: "somethingWentWrong".localized(),
            actions: [
                Action(
                    title: "retry".localized(),
                    style: .plain,
                    handler: { _ in retry() }
                )
            ]
        )
        return AlertViewController(configuration: configuration)
    }
}
