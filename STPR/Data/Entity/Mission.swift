//
//  Mission.swift
//  STPR
//
//  Created by Artur Chabera on 04/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

/**
 Get missions and tasks at start of app,
 maybe limit calls to every few days but it's not necessary for phase 2.
 path: mission_session
*/

enum MissionType: String, Codable {
    case seasonal
    case normal
    case sponsored
}

/**
 DocumentedMissionSession
    Struct added to store sessions and it's document IDs
    Needed to get path for updating session
 */
struct DocumentedMissionSession {
    var documentId: String
    var missionSession: MissionSession
}

struct MissionSession: Codable {
    let missionId: String
    var completedTasks: [TaskSession]
    var missionFinished: Bool
}

/**
 ghostPath - [latitude, longitude]
 times filed - seconds
*/

struct GhostPath: Decodable {
    let ghostPath: [Double]
    let ghostWalkTime: Double
    let ghostRestTime: Double
    let numberOfGhosts: Int
}

struct Mission: Decodable {
    let id: String
    let city: String
    let missionType: MissionType
    let requiredLevel: Int
    let title: [String: String]
    let fullStory: [String: String]
    let backgroundUrl: String
    let completionTime: Int
    let tasks: [Task]
    let ghostPath: GhostPath?
    let description: [String: String]
    let production: Bool
}
