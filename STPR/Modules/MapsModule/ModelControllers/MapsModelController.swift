//
//  MapsModelController.swift
//  STPR
//
//  Created by Artur Chabera on 30/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Kingfisher
import Combine

class MapsModelControlelr {
    typealias Dependencies = HasMissionsManager & HasUserManager & HasImageDownloader & HasTaskSessionController

    @Published var activeTask: Task? = nil
    @Published var availableMissions: [Mission] = []

    private let userManager: UserManager
    private let missionManager: MissionsManager
    private let imageDownloader: ImageDownloaderType
    let taskSessionController: TaskSessionController

    private var cancellables: Set<AnyCancellable> = []

    init(dependencies: Dependencies) {
        self.userManager = dependencies.userManager
        self.missionManager = dependencies.missionsManager
        self.imageDownloader = dependencies.imageDownloader
        self.taskSessionController = dependencies.taskSessionController
    }

    func fetchTask() {
        guard let userId = GlobalSettings.userId else { return }
        Publishers
            .CombineLatest3(
                missionManager.missionPublisher(),
                missionManager.sessionPublisher(userId: userId),
                userManager.sessionPublisher(userId: userId))
            .replaceError(with: ([], [], nil))
            .sink { [weak self] (missions, missionSessions, userSession) in
                let activeMissionId = userSession?.activeMissionId
                let activeTaskId = userSession?.activeTaskId
                
                self?.activeTask = missions
                    .first(where: { $0.id == activeMissionId })?
                    .tasks
                    .first(where: { $0.id == activeTaskId })

                let excludedMissions = missionSessions
                    .compactMap { $0.missionSession }
                    .filter { $0.completedTasks.isEmpty == false || $0.missionFinished }
                    .compactMap { $0.missionId }

                self?.availableMissions = missions
                    .filter { $0.id != activeMissionId }
                    .filter { !excludedMissions.contains($0.id) }
            }.store(in: &cancellables)
    }

    func makeMissionViewModel(for mission: Mission) -> SingleMissionViewModel {
        return SingleMissionViewModel(mission: mission, distance: 0.0)
    }

    func makeTaskViewModel(for task: Task) -> SingleTaskViewModel {
        return SingleTaskViewModel(task: task, session: nil)
    }

    func fetchImage(from url: String) -> AnyPublisher<UIImage, Error> {
        Just(url)
            .setFailureType(to: Error.self)
            .compactMap { URL(string: $0) }
            .flatMap { self.imageDownloader.downloadImage(using: $0) }
            .eraseToAnyPublisher()
    }

    func finishTask() {
        guard let task = activeTask else { return }
        taskSessionController.finish(task: task)
    }
}
