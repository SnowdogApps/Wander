//
//  MissionDetailsModelController.swift
//  STPR
//
//  Created by Artur Chabera on 18/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation
import Combine

final class MissionDetailsModelController {
    typealias Dependencies = HasMissionsManager & HasUserManager & HasTaskSessionController

    @Published private(set) var missionSession: MissionSession? = nil
    @Published private(set) var userSession: UserSession?
    @Published private(set) var missionFinished: Bool = false
    @Published private(set) var activeTask: Task? = nil
    @Published private(set) var progress: Double = 0.0

    private var cancellables: Set<AnyCancellable> = []
    private let mission: Mission
    private let missionsManager: MissionsManager
    private let userManager: UserManager
    private let taskSessionController: TaskSessionController

    init(dependencies: Dependencies, mission: Mission) {
        self.mission = mission
        self.missionsManager = dependencies.missionsManager
        self.userManager = dependencies.userManager
        self.taskSessionController = dependencies.taskSessionController

        $missionSession
            .compactMap { $0 }
            .sink { [weak self] in
                self?.progress = Double($0.completedTasks.count) / Double(mission.tasks.count)
            }.store(in: &cancellables)
    }

    func startMission() {
        if let missionSession = missionSession {
            startNextAvailableTask(for: missionSession)
        } else {
            createMissionSession()
        }
    }

    func fetch() {
        fetchUserSession()
        fetchMissionSession()
    }

    func finishMission() {
        guard var session = missionSession else { return }
        session.missionFinished = true
        updateMissionSession(with: session) { [weak self] in
            self?.missionFinished = true
            self?.activeTask = nil
        }
    }

    func startNextAvailableTask(for session: MissionSession) {
        if let nextTask = mission
            .tasks
            .first(where: {
                session
                    .completedTasks
                    .map { $0.taskId }
                    .contains($0.id) == false
        }) {
            updateUserSession(active: nextTask)
            activeTask = nextTask
        } else {
            finishMission()
        }
    }

    func abandonMission() {
        updateUserSession(active: nil)
        taskSessionController.abandonMission()
    }

    private func fetchMissionSession() {
        guard let userId = GlobalSettings.userId else { return }
        missionsManager
            .sessionPublisher(userId: userId)
            .retry(3)
            .replaceError(with: [])
            .map { $0.first { $0.missionSession.missionId == self.mission.id } }
            .compactMap { $0?.missionSession }
            .assign(to: \.missionSession, on: self)
            .store(in: &cancellables)
    }

    private func updateUserSession(active task: Task?) {
        guard
            let userId = GlobalSettings.userId,
            let userSession = userSession
            else { return }

        var updatedUserSession = userSession
        updatedUserSession.activeTaskId = task?.id ?? ""
        updatedUserSession.activeMissionId = task != nil ? mission.id : ""
        if mission.missionType == .seasonal {
            updatedUserSession.didCompleteTutorial = .skipped
        }

        userManager
            .updateSession(updatedUserSession, for: userId)
            .retry(3)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    #if DEBUG
                    print("Task in user sesion updated:\t", $0)
                    #endif
                }
            ).store(in: &cancellables)
    }

    private func fetchUserSession() {
        guard let userId = GlobalSettings.userId else { return }
        userManager
            .sessionPublisher(userId: userId)
            .replaceError(with: nil)
            .assign(to: \.userSession, on: self)
            .store(in: &cancellables)
    }

    private func updateMissionSession(with session: MissionSession, completion: @escaping () -> Void ) {
        guard
           let sessionId = GlobalSettings.currentMissionSessionId,
           let userId = GlobalSettings.userId
           else { return }

        missionsManager
            .updateSession(session, userId: userId, sessionId: sessionId)
            .replaceError(with: "")
            .sink { [weak self] _ in
                self?.fetchMissionSession()
                completion()
            }.store(in: &cancellables)
    }

    private func createMissionSession() {
        let missionSession = MissionSession(missionId: mission.id, completedTasks: [], missionFinished: false)
        guard let userId = GlobalSettings.userId else { return }
        missionsManager
            .createSession(missionSession, userId: userId)
            .retry(3)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    print("MISSION SESSION: \($0)")
                    GlobalSettings.currentMissionSessionId = $0
                    self?.fetchMissionSession()
                    self?.startMission()
                }
            )
            .store(in: &cancellables)
    }
}

/**
 Fabric methods for creating view models for subviews
 */

extension MissionDetailsModelController {
    func makeSingeMissionViewModel() -> SingleMissionViewModel {
        return SingleMissionViewModel(mission: mission, distance: 0.0)
    }

    func makeTaskViewModels() -> [SingleTaskViewModel] {
        return mission.tasks.compactMap { SingleTaskViewModel(task: $0, session: missionSession) }
    }
}
