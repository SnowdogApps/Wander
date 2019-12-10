//
//  User.swift
//  STPR
//
//  Created by Artur Chabera on 04/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

/**
UseCases:
- create/get session after user logs in using FirebaseAuth
- getUpdatableSession -> auto reloading session based on which state of the app will be shown.
  Firebase first writes updates locally so we get update immediately,
  so we can base UI updates based on session update when necessary
- Write to all fields
 
 path: users_v2
*/

enum TutorialStatus: String, Codable {
    case skipped
    case completed
}

struct UserSession: Codable {
    var experienceLevel: Int
    var gold: Int
    var username: String
    var activeMissionId: String
    var activeTaskId: String
    var didCompleteTutorial: TutorialStatus?
    let acceptedPrivacyPolicy: Bool
    var completedMissions: [String]
}

extension UserSession {
    static func makeEmpty(using username: String) -> UserSession {
        return UserSession(
            experienceLevel: 0,
            gold: 0,
            username: username,
            activeMissionId: "",
            activeTaskId: "",
            didCompleteTutorial: nil,
            acceptedPrivacyPolicy: true,
            completedMissions: []
        )
    }
}
