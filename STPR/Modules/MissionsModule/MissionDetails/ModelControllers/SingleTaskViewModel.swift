//
//  SingleTaskViewModel.swift
//  STPR
//
//  Created by Artur Chabera on 18/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

enum TaskState {
    case finished, available, failed
}

class SingleTaskViewModel {
    var image: URL? {
        return URL(string: task.backgroundUrl)
    }

    var title: String {
        return task.title[GlobalSettings.langCode] ?? ""
    }

    var hint: String {
        return task.hint[GlobalSettings.langCode] ?? ""
    }

    var description: String {
        return task.description[GlobalSettings.langCode] ?? ""
    }

    var story: String {
        return task.fullStory[GlobalSettings.langCode] ?? ""
    }

    var time: String? {
        let duration = TimeInterval(task.completionTime)
        return DateComponentsFormatter.duration.string(from: duration)
    }

    var completedMessage: String {
        return task.completedMessage[GlobalSettings.langCode] ?? ""
    }

    var state: TaskState {
        guard let session = session else { return .available }
        if let index = session.completedTasks.firstIndex(where: { $0.taskId == task.id }) {
            if session.completedTasks[index].completedState == .completed {
                return .finished
            } else {
                return .failed
            }
        } else {
            return .available
        }
    }

    var taskType: TaskType {
        return task.taskType
    }

    let task: Task
    let session: MissionSession?
    init(task: Task, session: MissionSession?) {
        self.task = task
        self.session = session
    }
}
