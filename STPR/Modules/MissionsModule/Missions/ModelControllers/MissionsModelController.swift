//
//  MissionsModelController.swift
//  STPR
//
//  Created by Artur Chabera on 13/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation
import Combine

class MissionsModelController {
    typealias Dependencies = HasMissionsManager & HasUserManager

    private let missionsManager: MissionsManager
    private let userManager: UserManager

    @Published private(set) var missions: [Mission] = []
    @Published private(set) var error: Error? = nil
    @Published private(set) var completed: [String] = []
    private var cancellables: Set<AnyCancellable> = []

    init(dependencies: Dependencies) {
        missionsManager = dependencies.missionsManager
        userManager = dependencies.userManager
    }

    func fetch() {
        guard let userId = GlobalSettings.userId else { return }
        Publishers
            .CombineLatest(
                missionsManager.missionPublisher(),
                userManager.sessionPublisher(userId: userId))
            .replaceError(with: ([], nil))
            .compactMap { (missions, user) -> [Mission] in
                guard let user = user else { return [] }
                if user.didCompleteTutorial != nil {
                    return missions
                } else {
                    return missions.filter { $0.missionType == .seasonal }
                }
            }
            .compactMap { missions in
                if AppConfig.isProductionRelease {
                    return missions.filter { $0.production == true }
                } else {
                    return missions
                }
            }
            .assign(to: \.missions, on: self)
            .store(in: &cancellables)

        userManager
            .sessionPublisher(userId: GlobalSettings.userId ?? "")
            .compactMap { $0?.completedMissions }
            .replaceError(with: [])
            .assign(to: \.completed, on: self)
            .store(in: &cancellables)
    }
    
    func makeSingleMissionModelController(for mission: Mission, distance: Double, isCompleted: Bool) -> SingleMissionViewModel {
        return SingleMissionViewModel(mission: mission, distance: distance, isCompleted: isCompleted)
    }
}
