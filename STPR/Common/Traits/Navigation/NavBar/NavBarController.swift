//
//  NavBarController.swift
//  STPR
//
//  Created by Artur Chabera on 03/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import SwiftUI

final class NavBarController: UIViewController {
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var experienceContainer: UIView!
    @IBOutlet weak var coinsImageView: UIImageView!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!

    @IBOutlet weak var navigationBarContainer: UIView!
    @IBOutlet weak var navigationViewContainer: UIView!
    
    private var experienceBar = ExperienceBar()

    var composeMailAction: () -> Void = { }
    weak var delegate: AppCoordinatorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        experienceContainer.addSubview(experienceBar)
        experienceBar.fit(to: experienceContainer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shadowSize: CGFloat = 10
        let contactRect = CGRect(
            x: -shadowSize,
            y: navigationBarContainer.frame.height - shadowSize / 2,
            width: navigationBarContainer.frame.width + shadowSize * 2,
            height: shadowSize
        )
        navigationBarContainer.layer.shadowPath = UIBezierPath(rect: contactRect).cgPath
        navigationBarContainer.layer.shadowRadius = 5
        navigationBarContainer.layer.shadowOpacity = 0.4
        navigationBarContainer.layer.shadowColor = UIColor.darkGray.cgColor
        navigationBarContainer.layer.zPosition = .greatestFiniteMagnitude
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        experienceBar.animateGradient()
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        navigationViewContainer.backgroundColor = .clear
        navigationBarContainer.backgroundColor = .containerBackground

        logoButton.imageView?.contentMode = .scaleAspectFill
        coinsImageView.image = UIImage(named: "coin")

        coinsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        coinsLabel.textColor = .secondaryFont

        avatarButton.titleLabel?.font = UIFont.iconFont(ofSize: 32)
        avatarButton.setTitle(UIFont.Icon.profile.rawValue, for: .normal)
        avatarButton.contentEdgeInsets = .zero

        levelLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        levelLabel.textColor = .secondaryFont
    }
    
    func add(rootController: NavigationController) {
        addChild(rootController, to: navigationViewContainer)
    }
    
    func update(userExperience: UserExperience) {
        experienceBar.experience = (userExperience.experience, userExperience.maxExperience)
        coinsLabel?.text = "\(userExperience.coins)"
        levelLabel?.text = "level".localized() + " \(userExperience.level)"
    }

    @IBAction func showSettings(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        var rootView = SettingsView()
        rootView.delegate = delegate

        let store = SettingStore(
            authManager: FirebaseAuthManager(),
            userManager: FirestoreUserManager(database: FirestoreManager())
        )
        let settingsVC = UIHostingController(rootView: rootView.environmentObject(store))
        settingsVC.modalPresentationStyle = .formSheet
        present(settingsVC, animated: true)
    }

    @IBAction func sendEmail(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        composeMailAction()
    }
}
