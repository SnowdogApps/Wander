//
//  TaskSessionViewModel.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/14/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

struct TaskSessionViewModel {
    var completedData: String? { DateFormatter.shortDate.string(from: Date(timeIntervalSince1970: session.completedDate)) }
    var isCompleted: Bool { session.completedState == .completed }
    var title: String? { task.title[GlobalSettings.langCode] }
    var subtitle: String? { task.description[GlobalSettings.langCode] }

    let session: TaskSession
    let task: Task
}
