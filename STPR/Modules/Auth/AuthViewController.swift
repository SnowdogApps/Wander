//
//  AuthViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/2/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import SafariServices
import FirebaseAuth
import Combine
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func userDidFinishedAuthorization()
}

final class AuthViewController: UIViewController {
    typealias Dependencies = HasAuthManager & HasUserManager

    private var termsUrl: URL {
        guard
            let stringUrl = Bundle.main.infoDictionary?["Terms URL"] as? String,
            let url = URL(string: stringUrl) else {
                fatalError("There is no Terms URL in info.plist or the URL is invalid")
        }
        return url
    }

    private var privacyUrl: URL {
        guard
            let stringUrl = Bundle.main.infoDictionary?["Privacy URL"] as? String,
            let url = URL(string: stringUrl) else {
                fatalError("There is no Privacy URL in info.plist or the URL is invalid")
        }
        return url
    }

    private enum Constants {
        enum TextFieldTags: Int {
            case email
            case password
            case username
        }
    }

    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var actionButton: FilledButton!
    @IBOutlet private weak var secondActionButton: UIButton!
    @IBOutlet private weak var buttonsHorizontalStack: UIStackView!
    @IBOutlet private weak var playAsGuestButton: UIButton!
    @IBOutlet private weak var resetPasswordButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emailTextField: CustomTextField!
    @IBOutlet private weak var passwordTextField: CustomTextField!
    @IBOutlet private weak var usernameTextField: CustomTextField!
    @IBOutlet private weak var privacySwitch: UISwitch!
    @IBOutlet private weak var privacyButton: UIButton!
    @IBOutlet private weak var privacyView: UIView!
    @IBOutlet private weak var termsSwitch: UISwitch!
    @IBOutlet private weak var termsButton: UIButton!
    @IBOutlet private weak var termsView: UIView!

    var action: AuthAction = .signUp {
        didSet {
            guard isViewLoaded else {
                return
            }
            setupLookAndFeel()
        }
    }

    weak var delegate: AuthViewControllerDelegate?

    private var cancellable: AnyCancellable?
    private let authManager: AuthManagerType
    private let userManager: UserManager

    init(dependencies: Dependencies) {
        self.authManager = dependencies.authManager
        self.userManager = dependencies.userManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLookAndFeel()
        setupTextFields()
        setupButtons()
    }

    private func setupLookAndFeel() {
        usernameTextField.isHidden = action == .login
        privacyView.isHidden = action == .login
        termsView.isHidden = action == .login
        privacySwitch.isOn = action == .login
        termsSwitch.isOn = action == .login
        titleLabel.text = action.title
        actionButton.setTitle(action.mainActionTitle, for: .normal)
        secondActionButton.setTitle(action.secondActionTitle, for: .normal)
        resetPasswordButton.isHidden = action == .signUp
        validateInputs()

        let animator = UIViewPropertyAnimator()

        animator.addAnimations {
            self.logoImageView.isHidden = self.action == .signUp
            self.buttonsHorizontalStack.axis = self.action == .signUp ? .vertical : .horizontal
            self.buttonsHorizontalStack.alignment = .center
        }

        animator.startAnimation()
    }

    private func setupTextFields() {
        view.backgroundColor = .appBackground
        view.hideKeyboardWhenTappedAround()
        titleLabel.textColor = .mainFont

        emailTextField.placeholder = "email".localized()
        emailTextField.textField.delegate = self
        emailTextField.configureTextField {
            $0.addTarget(self, action: #selector(validateInputs), for: .editingChanged)
            $0.tag = Constants.TextFieldTags.email.rawValue
            $0.textContentType = .emailAddress
            $0.keyboardType = .emailAddress
            $0.returnKeyType = .next
            $0.delegate = self
        }

        passwordTextField.placeholder = "password".localized()
        passwordTextField.textField.delegate = self
        passwordTextField.configureTextField {
            $0.tag = Constants.TextFieldTags.password.rawValue
            $0.textContentType = action == .login ? .password : .newPassword
            $0.keyboardType = .asciiCapable
            $0.isSecureTextEntry = true
            $0.returnKeyType = action == .login ? .send : .next
            $0.delegate = self
        }

        usernameTextField.placeholder = "username".localized()
        usernameTextField.textField.delegate = self
        usernameTextField.configureTextField {
            $0.tag = Constants.TextFieldTags.username.rawValue
            $0.textContentType = .nickname
            $0.delegate = self
            $0.returnKeyType = .send
        }
    }

    private func setupButtons() {
        let privacyTitle: NSAttributedString = .underline(
            "privacyUnderline".localized(),
            in: "acceptPrivacy".localized()
        )
        privacyButton.setAttributedTitle(privacyTitle, for: .normal)
        privacyButton.titleLabel?.numberOfLines = 0

        let termsTitle: NSAttributedString = .underline(
            "termsUnderline".localized(),
            in: "acceptTerms".localized()
        )
        termsButton.setAttributedTitle(termsTitle, for: .normal)
        termsButton.titleLabel?.numberOfLines = 0

        resetPasswordButton.setTitleColor(.mainFont, for: .normal)
        resetPasswordButton.setAttributedTitle(.underlined("resetPassword".localized()), for: .normal)

        playAsGuestButton.setTitleColor(.mainFont, for: .normal)
        playAsGuestButton.setAttributedTitle(.underlined("playAsGuest".localized()), for: .normal)

        validateInputs()
    }

    @IBAction func switchValueChanged() {
        validateInputs()
    }

    @IBAction func presentPrivacy() {
        let safariVC = SFSafariViewController(url: privacyUrl)
        present(safariVC, animated: true)
    }

    @IBAction func presentTerms() {
        let safariVC = SFSafariViewController(url: termsUrl)
        present(safariVC, animated: true)
    }

    @discardableResult
    @objc
    private func validateInputs() -> Bool {
        let emailRegex = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES[c] %@", emailRegex)
        let isValidEmail = emailPredicate.evaluate(with: emailTextField.text)
        emailTextField.errorMessage = isValidEmail || emailTextField.text.isNilOrEmpty
            ? nil : "invalidEmail".localized()

        let isValidPassword = passwordTextField.text.map { $0.count > 6 } ?? false
        passwordTextField.errorMessage = isValidPassword || passwordTextField.text.isNilOrEmpty
            ? nil : "invalidPassword".localized()

        let isValidUsername = usernameTextField.text.map { $0.count > 4 } ?? false
        usernameTextField.errorMessage = isValidUsername || usernameTextField.text.isNilOrEmpty
            ? nil : "invalidUsername".localized()

        let isValid = privacySwitch.isOn && termsSwitch.isOn &&
            isValidEmail && isValidPassword && isValidUsername
        actionButton.isEnabled = isValid
        return isValid
    }

    @IBAction func playAsGuest() {
        setActivityStatus(.visible(text: nil))
        cancellable = authManager
            .loginAsGuest()
            .flatMap { user -> AnyPublisher<UserSession?, Error> in
                GlobalSettings.userId = user.uid
                let session = UserSession.makeEmpty(using: "anonymous".localized())
                return self.userManager.createSessionIfNeeded(session, for: user.uid)
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }

                self.setActivityStatus(.hidden)
                if case let .failure(error) = completion {
                    self.presentError(error, retry: self.playAsGuest)
                } else {
                    self.delegate?.userDidFinishedAuthorization()
                }
            }, receiveValue: { _ in }
        )
    }

    @IBAction func presentResetPasswordAlert() {
        let alert = AlertViewController.makeResetPassword { email in
            self.cancellable = self.authManager
                .resetPassword(for: email)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        guard let self = self else {
                            return
                        }

                        if case let .failure(error) = completion {
                            self.presentError(error, retry: self.presentResetPasswordAlert)
                        } else {
                            let alert = AlertViewController.make(title: "passwordResetMailSent".localized())
                            self.present(alertController: alert)
                        }
                    }, receiveValue: { _ in }
            )
        }

        PopupPresenter(contentViewController: alert)
            .present(in: self, completion: nil)
    }

    private func authPublisher() -> AnyPublisher<User, Error> {
        if action == .signUp {
            return authManager.signUp(
                email: emailTextField.text ?? "",
                password: passwordTextField.text ?? ""
            ).eraseToAnyPublisher()
        } else {
            return authManager.login(
                email: emailTextField.text ?? "",
                password: passwordTextField.text ?? ""
            ).eraseToAnyPublisher()
        }
    }

    @IBAction func executeAction() {
        guard validateInputs() else { return }
        setActivityStatus(.visible(text: nil))
        cancellable = authPublisher()
            .flatMap { user -> AnyPublisher<UserSession?, Error> in
                GlobalSettings.userId = user.uid
                let username = self.usernameTextField.text ?? ""
                let session = UserSession.makeEmpty(using: username)
                return self.userManager.createSessionIfNeeded(session, for: user.uid)
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }

                self.setActivityStatus(.hidden)
                if case let .failure(error) = completion {
                    self.presentError(error, retry: self.executeAction)
                } else {
                    self.delegate?.userDidFinishedAuthorization()
                }
            },
            receiveValue: { _ in }
        )
    }

    @IBAction func executeSecondAction() {
        switch action {
        case .signUp: action = .login
        case .login: action = .signUp
        }
    }
}

extension AuthViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        validateInputs()

        guard
            textField.tag == Constants.TextFieldTags.email.rawValue,
            let text = textField.text, text.contains("@")
            else { return true }

        let username = emailTextField.text?.components(separatedBy: "@").first
        usernameTextField.text =  username?.lowercased()

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case Constants.TextFieldTags.email.rawValue: passwordTextField.textField.becomeFirstResponder()
        case Constants.TextFieldTags.password.rawValue:
            switch action {
            case .login: executeAction()
            case .signUp: usernameTextField.textField.becomeFirstResponder()
            }
        case Constants.TextFieldTags.username.rawValue: executeAction()
        default: textField.resignFirstResponder()
        }
        return false
    }
}

extension AuthViewController: ActivityPresentable {}
