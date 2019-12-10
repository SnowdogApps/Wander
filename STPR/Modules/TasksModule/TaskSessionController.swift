//
//  TaskSessionController.swift
//  STPR
//
//  Created by Artur Chabera on 08/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Foundation
import Combine

final class TaskSessionController {
    private let userManager: UserManager
    private let missionsManager: MissionsManager
    private var cancellables: Set<AnyCancellable> = []

    @Published var missionFinished: Bool? = nil
    private(set) var missionSession: MissionSession? = nil
    private var task: Task?

    init(userManager: UserManager, missionsManager: MissionsManager) {
        self.userManager = userManager
        self.missionsManager = missionsManager
    }

    private func taskListener() {
        guard let userId = GlobalSettings.userId, !userId.isEmpty else { return }
        Publishers
            .CombineLatest3(
                missionsManager.missionPublisher(),
                missionsManager.sessionPublisher(userId: userId),
                userManager.sessionPublisher(userId: userId))
            .replaceError(with: ([], [], nil))
            .compactMap { ($0.0, $0.1.compactMap { $0.missionSession }, $0.2) }
            .sink { [weak self] (missions, missionSessions, userSession) in
                let currentMissionId = userSession?.activeMissionId
                guard
                    let activeTaskId = userSession?.activeTaskId,
                    let currentSession = missionSessions
                        .first(where: { $0.missionId == currentMissionId }),
                    let currentMission = missions.first(where: { $0.id == currentMissionId }),
                    currentSession.completedTasks
                        .compactMap({ $0.taskId })
                        .contains(activeTaskId)
                    else { return }
                self?.missionSession = currentSession
                self?.updateUserSession(
                    mission: currentMission,
                    missionSession: currentSession,
                    userSession: userSession)
        }.store(in: &cancellables)
    }

    private func resetMissionSession() {
        $missionFinished
            .receive(on: RunLoop.main)
            .replaceError(with: nil)
            .sink { [weak self] missionFinished in
                guard
                    let missionFinished = missionFinished,
                    !missionFinished
                    else { return }
                self?.missionSession = nil
                self?.missionFinished = nil
                self?.cancellables.forEach { $0.cancel() }
                self?.cancellables.removeAll()
                self?.fetchMissionSession()
                self?.taskListener()
        }.store(in: &cancellables)
    }

    func abandonMission() {
        missionSession = nil
        missionFinished = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    private func fetchMissionSession() {
        guard let userId = GlobalSettings.userId else { return }
        Publishers
            .Zip3(
                userManager.sessionPublisher(userId: userId),
                missionsManager.sessionPublisher(userId: userId),
                missionsManager.missionPublisher()
            )
            .replaceError(with: (nil, [], []))
            .sink { [weak self] (userSession, documentedMissionSessions, missions) in
                let currentMission = missions
                    .first { $0.id == userSession?.activeMissionId }

                guard let currentSession = documentedMissionSessions
                        .first(where: { $0.missionSession.missionId == currentMission?.id })
                    else { return }

                GlobalSettings.currentMissionSessionId = currentSession.documentId
                self?.missionSession = currentSession.missionSession

                self?.updateMissionSession(with: self?.task)
            }.store(in: &cancellables)
    }

    func finish(task: Task) {
        self.task = task
        if missionSession != nil {
            updateMissionSession(with: task)
        } else {
            fetchMissionSession()
            taskListener()
            resetMissionSession()
        }
    }

    private func updateMissionSession(with task: Task?) {
        guard var session = missionSession,
            let sessionId = GlobalSettings.currentMissionSessionId,
            let userId = GlobalSettings.userId,
            let task = task
            else { return }

        let completedTask = TaskSession(
            taskId: task.id,
            completedState: .completed,
            acquiredExp: task.exp,
            completedDate: Date().timeIntervalSince1970,
            selectedNextTask: task.nextTaskIds?.first
        )
        session.completedTasks.append(completedTask)

        missionsManager
            .updateSession(session, userId: userId, sessionId: sessionId)
            .replaceError(with: "")
            .sink { [weak self] _ in self?.task = nil }
            .store(in: &cancellables)
    }

    private func updateUserSession(mission: Mission, missionSession: MissionSession, userSession: UserSession?) {
        guard
            let userId = GlobalSettings.userId,
            var updatedUserSession = userSession
            else { return }

        if let nextTask = getNextTask(in: missionSession, from: mission) {
            updatedUserSession.activeTaskId = nextTask.id
        } else {
            updatedUserSession.activeTaskId = ""
            updatedUserSession.activeMissionId = ""
            updatedUserSession.completedMissions.append(mission.id)
            if mission.missionType == .seasonal {
                updatedUserSession.didCompleteTutorial = .completed
            }
            finishMission(missionSession: missionSession)
        }

        updatedUserSession.experienceLevel = updatedUserSession.experienceLevel + (self.task?.exp ?? 0)
        updatedUserSession.gold = updatedUserSession.gold + (task?.coin ?? 0)

        userManager
            .updateSession(updatedUserSession, for: userId)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] value in
                    self?.task = nil
                    self?.missionSession = missionSession
                }
            ).store(in: &cancellables)
    }

    private func finishMission(missionSession: MissionSession?) {
        guard
            var session = missionSession,
            let userId = GlobalSettings.userId,
            let sessionId = GlobalSettings.currentMissionSessionId
            else { return }

        session.missionFinished = true
        missionsManager
            .updateSession(session, userId: userId, sessionId: sessionId)
            .replaceError(with: "")
            .sink { [weak self] _ in
                self?.missionFinished = true
        }.store(in: &cancellables)
    }

    private func getNextTask(in session: MissionSession, from mission: Mission) -> Task? {
        return mission.tasks
            .first {
                session.completedTasks
                    .compactMap { $0.taskId }
                    .contains($0.id) == false
            }
    }
}
