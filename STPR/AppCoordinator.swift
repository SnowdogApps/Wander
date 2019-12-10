//
//  AppCoordinatorController.swift
//  STPR
//
//  Created by Artur Chabera on 27/08/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

protocol AppCoordinatorDelegate: AnyObject {
    func openTab(_ tab: Int)
    func logout()
}

final class AppCoordinator {
    private let window: UIWindow
    private let dependencies: Dependencies
    private var tabBar: TabBarController!
    
    init(window: UIWindow, dependencies: Dependencies) {
        self.window = window
        self.dependencies = dependencies
    }
    
    func start() {
        GlobalSettings.langCode = Locale.autoupdatingCurrent.languageCode ?? "en"
        if GlobalSettings.isUserBoarded {
            if GlobalSettings.userId.isNilOrEmpty {
                startAuth()
            } else {
                startApp()
            }
        } else {
            startOnboarding()
        }
    }

    func startOnboarding() {
        let onboardingVC = OnboardingViewController(modelController: .makeOnboarding(with: dependencies))
        onboardingVC.delegate = self
        window.rootViewController = onboardingVC
    }

    func startApp() {
        tabBar = TabBarController(modules: setupControllers())
        window.rootViewController = tabBar
        tabBar.selectTab(index: 2)
        checkForGalileoAlert()
        dependencies.userExperienceManager.setupUserListener()
    }

    func startAuth() {
        let authVC = AuthViewController(dependencies: dependencies)
        authVC.delegate = self
        window.rootViewController = authVC
    }
}

extension AppCoordinator: AuthViewControllerDelegate {
    func userDidFinishedAuthorization() {
        start()
    }
}

extension AppCoordinator: OnboardingDelegate {
    func onboardingDidFinished() {
        start()
    }
}

extension AppCoordinator: AppCoordinatorDelegate {
    func openTab(_ tab: Int) {
        tabBar.selectTab(index: tab)
    }

    func logout() {
        start()
    }
}

extension AppCoordinator {
    private func setupControllers() -> [TabBarModule] {
        return [
            TabBarModule(
                coordinator: SocialCoordinatorController(dependencies: dependencies),
                button: TabBarButton(icon: .social, style: .standard, text: "social".localized()),
                delegate: self
            ),
            TabBarModule(
                coordinator: MissionsCoordinatorController(dependencies: dependencies),
                button: TabBarButton(icon: .missions, style: .standard, text: "missions".localized()),
                delegate: self
            ),
            TabBarModule(
                coordinator: CameraCoordinatorController(dependencies: dependencies),
                button: TabBarButton(icon: nil, style: .central, text: nil),
                delegate: self
            ),
            TabBarModule(
                coordinator: MapsCoordinatorController(dependencies: dependencies),
                button: TabBarButton(icon: .map, style: .standard, text: "map".localized()),
                delegate: self
            ),
            TabBarModule(
                coordinator: ProfileCoordinatorController(dependencies: dependencies),
                button: TabBarButton(icon: .profile, style: .standard, text: "profile".localized()),
                delegate: self
            )
        ]
    }
}

extension AppCoordinator {
    private func checkForGalileoAlert() {
        if GlobalSettings.appOpenedWithoutNofiticationCount > 14 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIApplication.topViewController()?.present(alertController: .makeGalileoAlert())
            }
            GlobalSettings.appOpenedWithoutNofiticationCount = 0
        } else {
            GlobalSettings.appOpenedWithoutNofiticationCount += 1
        }
    }
}
