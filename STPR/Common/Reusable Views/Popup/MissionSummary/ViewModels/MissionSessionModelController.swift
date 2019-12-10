//
//  MissionSessionViewModel.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/14/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Combine
import Foundation

final class MissionSessionModelController {
    typealias Dependencies = HasMissionsManager

    var totalXP: Int {
        session.completedTasks.map { $0.acquiredExp }.reduce(0, +)
    }

    var title: String {
        mission?.title[GlobalSettings.langCode] ?? ""
    }

    private let missionManager: MissionsManager
    private let session: MissionSession

    @Published private(set) var mission: Mission?
    private var cancellable: AnyCancellable?

    var taskSessionViewModels: [TaskSessionViewModel] {
        guard let mission = mission else {
            return []
        }

        return session.completedTasks.compactMap { session in
            guard let task = mission.tasks.first(where: { $0.id == session.taskId }) else {
                return nil
            }
            return TaskSessionViewModel(session: session, task: task)
        }
    }

    init(dependencies: Dependencies, session: MissionSession) {
        self.missionManager = dependencies.missionsManager
        self.session = session
    }

    func fetch() {
        cancellable = missionManager
            .missionPublisher()
            .replaceError(with: [])
            .map { $0.first { $0.id == self.session.missionId } }
            .assign(to: \.mission, on: self)
    }
}
