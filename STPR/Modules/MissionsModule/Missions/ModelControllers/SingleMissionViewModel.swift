//
//  SingleMissionModelController.swift
//  STPR
//
//  Created by Artur Chabera on 16/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

class SingleMissionViewModel {
    var backgroundUrl: URL? { return URL(string: mission.backgroundUrl) }
    var time: String { return "\(mission.completionTime) \("min".localized())" }
    var distanceFormatted: String {
        switch distance {
        case _ where distance < 1_000:
            return "\(Int(distance)) \("meters".localized())"
        case _ where distance >= 1_000 && distance < 10_000:
            let kilometers = distance / 1_000
            let formattedDistance = round(kilometers * 100) / 100
            return "\(formattedDistance) \("kilometers".localized())"
        default:
            return "\(Int(distance / 1_000)) \("kilometers".localized())"
        }
    }
    var title: String { return mission.title[GlobalSettings.langCode] ?? "" }
    var fullStory: String { return mission.fullStory[GlobalSettings.langCode] ?? "" }
    var missionDescription: String { return mission.description[GlobalSettings.langCode] ?? "" }
    var city: String { return mission.city }
    var coins: String {
        let coins = mission
            .tasks
            .compactMap { $0.coin }
            .reduce(0, +)
        return "\(coins)"
    }
    var exp: String {
        let experience = mission
            .tasks
            .compactMap { $0.exp }
            .reduce(0, +)
        return "\(experience)"
    }

    private let mission: Mission
    private let distance: Double
    let isCompleted: Bool

    init(mission: Mission, distance: Double, isCompleted: Bool = false) {
        self.isCompleted = isCompleted
        self.mission = mission
        self.distance = distance
    }
}
