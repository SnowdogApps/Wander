//
//  Task.swift
//  STPR
//
//  Created by Artur Chabera on 04/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

/**
 UseCases:
 - getUpdatableMission - we use this as auto reloading data for mission details to get task states
 - Add mission/task to session
 NOTE!! there may be more than one mission for id, look for non completed one
*/

struct TaskSession: Codable {
    let taskId: String
    let completedState: CompletedState
    let acquiredExp: Int
    let completedDate: Double
    let selectedNextTask: String?
}

enum CompletedState: String, Codable {
    case completed = "completed"
    case outOfTime = "out_of_time"
    case failed = "failed"
}

enum TaskType: String, Codable {
    case showItemToCamera
    case goToLocation
    case leaveLocation
    case collectItems
    case scanMarker
    case question
    case selectPath
}

struct Task: Decodable {
    let id: String
    let backgroundUrl: String
    let coin: Int
    let exp: Int
    let completionTime: Int
    let description: [String: String]
    let fullStory: [String: String]
    let hint: [String: String]
    let title: [String: String]
    let nextTaskIds: [String]?
    let taskType: TaskType
    let longitude: Double
    let latitude: Double
    let completedMessage: [String: String]

    /// Show item to camera
    private let mlModelUrl: String?
    private let acceptThreshold: Double?
    private let lastMeasureWeight: Double?
    private let modelClasses: [String]?

    /// Go to location
    private let detectionRadius: Double?

    /// Leave location
    private let escapeRadius: Double?

    /// Collect items
    private let itemUrl: String?
    private let name: [String: String]?
    private let numberOfItems: Int?
    private let spreadingRadius: Double?
    private let collectingRadius: Double?
    private let requiredNumberOfItems: Int?

    /// Scan marker
    private let markerUrl: String?
    private let overlayUrl: String?
    private let videoUrl: String?
    private let width: Double?
    private let height: Double?

    /// Question
    private let question: [String: String]?
    private let multipleAnswerOptions: [String: [String]]?
    private let correctAnswer: Int?

    /// Selected path
    private let pathDescription: [String: String]?
    private let pathOptions: [String: [String]]?
}

extension Task {
    var showItemToCamera: ShowItemToCameraData? {
        guard taskType == .showItemToCamera else { return nil }
        return ShowItemToCameraData(
            mlModelUrl: mlModelUrl ?? "",
            acceptThreshold: acceptThreshold ?? 0.0,
            lastMeasureWeight: lastMeasureWeight ?? 0.0,
            modelClasses: modelClasses ?? []
        )
    }

    var goToLocationData: GoToLocationData? {
        guard taskType == .goToLocation else { return nil }
        return GoToLocationData(
            longitude: longitude,
            latitude: latitude,
            detectionRadius: detectionRadius ?? 0.0
        )
    }

    var leaveLocationData: LeaveLocationData? {
        guard taskType == .leaveLocation else { return nil }
        return LeaveLocationData(
            longitude: longitude,
            latitude: latitude,
            escapeRadius: escapeRadius ?? 0.0
        )
    }

    var collectItemsData: CollectItemsData? {
        guard taskType == .collectItems else { return nil }
        return CollectItemsData(
            itemUrl: itemUrl ?? "",
            name: name ?? [:],
            numberOfItems: numberOfItems ?? 0,
            spreadingRadius: spreadingRadius ?? 0.0,
            collectingRadius: collectingRadius ?? 0.0,
            requiredNumberOfItems: requiredNumberOfItems ?? 0
        )
    }

    var scanMarkerData: ScanMarkerData? {
        guard taskType == .scanMarker else { return nil }
        return ScanMarkerData(
            markerUrl: markerUrl ?? "",
            overlayUrl: overlayUrl,
            videoUrl: videoUrl,
            width: width ?? 0.0,
            height: height ?? 0.0
        )
    }

    var questionData: QuestionData? {
        guard taskType == .question else { return nil }
        return QuestionData(
            question: question ?? [:],
            multipleAnswerOptions: multipleAnswerOptions ?? [:],
            correctAnswer: correctAnswer ?? 0
        )
    }

    var selectedPath: SelectPathData? {
        guard taskType == .selectPath else { return nil }
        return SelectPathData(
            pathDescription: pathDescription ?? [:],
            pathOptions: pathOptions ?? [:]
        )
    }
}

struct ShowItemToCameraData: Decodable {
    let mlModelUrl: String
    let acceptThreshold: Double
    let lastMeasureWeight: Double
    let modelClasses: [String]
}

struct GoToLocationData: Decodable {
    let longitude: Double
    let latitude: Double
    let detectionRadius: Double
}

struct LeaveLocationData: Decodable {
    let longitude: Double
    let latitude: Double
    let escapeRadius: Double
}

struct CollectItemsData: Decodable {
    let itemUrl: String
    let name: [String: String]
    let numberOfItems: Int
    let spreadingRadius: Double
    let collectingRadius: Double
    let requiredNumberOfItems: Int
}

struct ScanMarkerData: Decodable {
    let markerUrl: String
    let overlayUrl: String?
    let videoUrl: String?
    let width: Double
    let height: Double
}

struct QuestionData: Decodable {
    let question: [String: String]
    let multipleAnswerOptions: [String: [String]]
    let correctAnswer: Int
}

struct SelectPathData: Decodable {
    let pathDescription: [String: String]
    let pathOptions: [String: [String]]
}
