//
//  CameraModelController.swift
//  STPR
//
//  Created by Artur Chabera on 12/11/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation
import Combine

final class CameraModelController {

    typealias Dependencies = HasUserManager & HasMissionsManager & HasTaskSessionController & HasImageDownloader
    private let dependencies: Dependencies
    private let userManager: UserManager
    private let missionsManager: MissionsManager
    private let taskSessionController: TaskSessionController
    private var scanMarkerModelController: ScanMarkerModelController?
    private var cancellables: Set<AnyCancellable> = []

    @Published private(set) var task: Task? = nil
    @Published private(set) var missionFinished: Bool? = nil

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.userManager = dependencies.userManager
        self.missionsManager = dependencies.missionsManager
        self.taskSessionController = dependencies.taskSessionController
    }

    func fetch() {
        guard let userID = GlobalSettings.userId else { return }
        Publishers
            .CombineLatest(userManager.sessionPublisher(userId: userID), missionsManager.missionPublisher())
            .receive(on: RunLoop.main)
            .replaceError(with: (nil, []))
            .sink { [weak self] (userSession, missions) in
                let activeMissionId = userSession?.activeMissionId
                let activeTaskId = userSession?.activeTaskId

                self?.task = missions
                   .first(where: { $0.id == activeMissionId })?
                   .tasks
                   .first(where: { $0.id == activeTaskId })

        }.store(in: &cancellables)
    }

    func setFinishedMissionListener() {
        taskSessionController
            .$missionFinished
            .receive(on: DispatchQueue.main)
            .replaceError(with: false)
            .assign(to: \.missionFinished, on: self)
            .store(in: &cancellables)
    }

    func makeSingleTaskViewModel(task: Task?, session: MissionSession?) -> SingleTaskViewModel? {
        guard let task = task else { return nil }
        return SingleTaskViewModel(task: task, session: session)
    }

    func getTaskSessionController() -> TaskSessionController {
        return taskSessionController
    }

    func makeMissionSessionModelController() -> MissionSessionModelController? {
        guard let missionSession = taskSessionController.missionSession else { return nil }
        return MissionSessionModelController(dependencies: dependencies, session: missionSession)
    }

    func makeScanMarkerModelController() -> ScanMarkerModelController? {
        guard let data = task?.scanMarkerData else { return nil }
        return ScanMarkerModelController(scanMarkerData: data, dependencies: dependencies)
    }
}
