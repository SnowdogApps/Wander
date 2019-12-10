//
//  OnboardingModelController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/24/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import AVKit
import Combine
import CoreLocation

final class OnboardingModelController: NSObject {
    typealias Dependencies = HasLocationManager & HasUserManager

    let permissionsNeeded: Bool
    let pages: [OnboardingPage]

    private var cancellables: Set<AnyCancellable> = []
    private let permissionsSubject = PassthroughSubject<Bool, Error>()
    private let locationManager: CLLocationManager
    private let userManager: UserManager

    init(pages: [OnboardingPage], permissionsNeeded: Bool, dependencies: Dependencies) {
        self.locationManager = dependencies.locationManager
        self.userManager = dependencies.userManager
        self.permissionsNeeded = permissionsNeeded
        self.pages = pages
    }

    func finishBoarding() {
        GlobalSettings.isUserBoarded = true
    }

    func requestPermissionsPublisher() -> AnyPublisher<Bool, Error> {
        locationManager.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        default:
            permissionsSubject.send(true)
            requestCapturePermission()
        }

        return permissionsSubject.eraseToAnyPublisher()
    }

    private func requestCapturePermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionsSubject.send(true)
            permissionsSubject.send(completion: .finished)
        default:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] result in
                self?.permissionsSubject.send(result)
                self?.permissionsSubject.send(completion: .finished)
            }
        }
    }
}

extension OnboardingModelController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        permissionsSubject.send(status == .authorizedWhenInUse)
        requestCapturePermission()
    }
}

extension OnboardingModelController {
    static func makeOnboarding(with dependencies: Dependencies) -> OnboardingModelController {
        var pages: [OnboardingPage] = [
            OnboardingPage(
                image: "bigLogo",
                title: "onboardingPage0Title".localized(),
                content: "onboardingPage0SubTitle".localized(),
                action: "next".localized()
            ),
            OnboardingPage(
                image: "toolbar",
                title: "onboardingPage1Title".localized(),
                content: "onboardingPage1SubTitle".localized(),
                action: "next".localized()
            ),
            OnboardingPage(
                image: "mission",
                title: "onboardingPage2Title".localized(),
                content: "onboardingPage2SubTitle".localized(),
                action: "next".localized()
            ),
            OnboardingPage(
                image: "win",
                title: "onboardingPage3Title".localized(),
                content: "onboardingPage3SubTitle".localized(),
                action: "next".localized()
            ),
            OnboardingPage(
                image: "map",
                title: "onboardingPage4Title".localized(),
                content: "onboardingPage4SubTitle".localized(),
                action: "next".localized()
            ),
            OnboardingPage(
                image: "map_2",
                title: "onboardingPage5Title".localized(),
                content: "onboardingPage5SubTitle".localized(),
                action: "next".localized()
            )
        ]

        pages.append(
            OnboardingPage(
                image: "sticker_galileo",
                title: "galileoTitle".localized(),
                content: "galileoSubTitle".localized(),
                action: "start".localized()
            )
        )

        let controller = OnboardingModelController(
            pages: pages,
            permissionsNeeded: true,
            dependencies: dependencies
        )

        return controller
    }
}
