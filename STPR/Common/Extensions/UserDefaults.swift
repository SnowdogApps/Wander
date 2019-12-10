//
//  UserDefaults.swift
//  STPR
//
//  Created by Artur Chabera on 24/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

private enum Key: String {
    case userBoarded
    case userId
    case currentMissionSessionId
    case langCode
    case appOpenedWithoutNofiticationCount
}

@propertyWrapper
struct Defaults<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get { return UserDefaults.standard.value(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

enum GlobalSettings {
    @Defaults(key: Key.userBoarded.rawValue, defaultValue: false)
    static var isUserBoarded: Bool

    @Defaults(key: Key.userId.rawValue, defaultValue: nil)
    static var userId: String?

    @Defaults(key: Key.currentMissionSessionId.rawValue, defaultValue: nil)
    static var currentMissionSessionId: String?

    @Defaults(key: Key.langCode.rawValue, defaultValue: "en")
    static var langCode: String

    @Defaults(key: Key.appOpenedWithoutNofiticationCount.rawValue, defaultValue: 0)
    static var appOpenedWithoutNofiticationCount: Int
}
