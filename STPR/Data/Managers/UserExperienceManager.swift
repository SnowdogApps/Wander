//
//  UserExperienceManager.swift
//  STPR
//
//  Created by Artur Chabera on 21/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Combine
import Foundation

fileprivate let expDict: [Int: Int] = [
    1: 0,
    2: 100,
    3: 200,
    4: 400,
    5: 800,
    6: 1500,
    7: 2600,
    8: 4200,
    9: 6400,
    10: 9300,
    11: 13000,
    12: 17600,
    13: 23200,
    14: 29900,
    15: 37800,
    16: 47000,
    17: 57600,
    18: 69700,
    19: 83400,
    20: 98800
]

struct UserExperience {
    let level: Int
    let experience: Int
    let maxExperience: Int
    let coins: Int
}

class UserExperienceManager {
    @Published var userExperience: UserExperience? = nil

    private let userManager: UserManager
    private var cancellable: AnyCancellable? = nil

    init(userManager: UserManager) {
        self.userManager = userManager
    }

    func setupUserListener() {
        guard let userId = GlobalSettings.userId, !userId.isEmpty, cancellable == nil else { return }
        cancellable = userManager
            .sessionPublisher(userId: userId)
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink { [weak self] userSession in
                guard let userSession = userSession else { return }
                let currentExp = userSession.experienceLevel

                let level = expDict
                    .sorted { $0.value > $1.value }
                    .first { $0.1 <= currentExp }
                    .map { $0.0 } ?? 0

                let maxExp = (expDict[level + 1] ?? 98_800) - 1
                let minExpForLevel = (expDict[level] ?? 0)
                let expInterpolated =  currentExp - minExpForLevel
                let maxExpInterpolated = maxExp - minExpForLevel

                self?.userExperience = UserExperience(
                    level: level,
                    experience: expInterpolated,
                    maxExperience: maxExpInterpolated,
                    coins: userSession.gold
                )
        }
    }
}
