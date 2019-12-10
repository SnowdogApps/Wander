//
//  Dependencies.swift
//  STPR
//
//  Created by Artur Chabera on 15/04/2019.
//  Copyright © 2019 Artur Chabera. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation

struct Dependencies: HasMissionsManager, HasUserManager,
            HasLocationManager, HasImageDownloader, HasAuthManager,
            HasTaskSessionController, HasUserExperienceManager {
    let missionsManager: MissionsManager
    let userManager: UserManager
    let locationManager: CLLocationManager
    let imageDownloader: ImageDownloaderType
    let authManager: AuthManagerType
    let taskSessionController: TaskSessionController
    let userExperienceManager: UserExperienceManager
}

protocol HasUserDefaults {
    var userDefaults: UserDefaults { get }
}

protocol HasMissionsManager {
    var missionsManager: MissionsManager { get }
}

protocol HasLocationManager {
    var locationManager: CLLocationManager { get }
}

protocol HasUserManager {
    var userManager: UserManager { get }
}

protocol HasImageDownloader {
    var imageDownloader: ImageDownloaderType { get }
}

protocol HasAuthManager {
    var authManager: AuthManagerType { get }
}

protocol HasTaskSessionController {
    var taskSessionController: TaskSessionController { get }
}

protocol HasUserExperienceManager {
    var userExperienceManager: UserExperienceManager { get }
}
