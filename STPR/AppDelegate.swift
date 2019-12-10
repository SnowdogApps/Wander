//
//  AppDelegate.swift
//  STPR
//
//  Created by Artur Chabera on 12/02/2019.
//  Copyright © 2019 Artur Chabera. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher
import Firebase
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!

    lazy var dependencies: Dependencies = {
        let databaseManager = FirestoreManager(database: Firestore.firestore())
        let missionsManager = FirestoreMissionsManager(database: databaseManager)
        let userManager = FirestoreUserManager(database: databaseManager)

        return Dependencies (
            missionsManager: missionsManager,
            userManager: userManager,
            locationManager: CLLocationManager(),
            imageDownloader: ImageDownloader.default,
            authManager: FirebaseAuthManager(),
            taskSessionController: TaskSessionController(
                userManager: userManager,
                missionsManager: missionsManager
            ),
            userExperienceManager: UserExperienceManager(userManager: userManager)
        )
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if DEBUG
            print("<----------------------- SESSIONS DATA ------------------------>")
            print("User session id:\t", GlobalSettings.userId ?? "NO USER")
            print("Mission session id:\t", GlobalSettings.currentMissionSessionId ?? "NO CURRENT MISSION")
            print("<-------------------------------------------------------------->")
        #endif
        setupAppearances()
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator(window: window!, dependencies: dependencies)
        appCoordinator.start()
        window?.makeKeyAndVisible()

        guard
            let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let GMSApiKey = dict.object(forKey: "GMSApiKey") as? String
            else { fatalError("Cannot find Info.plist API Key for GMS") }
        GMSServices.provideAPIKey(GMSApiKey)
        return true
    }

    private func setupAppearances() {
        PageControl.appearance().currentPageIndicatorTintColor = .appYellow
    }
}
