//
//  AppConfig.swift
//  STPR
//
//  Created by Artur Chabera on 05/11/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

enum AppConfig {
    static var isProductionRelease: Bool {
        Bundle.main.infoDictionary?["ProductionRelease"] as? Bool ?? false
    }
}
