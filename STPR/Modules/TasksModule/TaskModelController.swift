//
//  TaskModelController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/1/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Foundation
import Combine

final class TaskModelController {
    var title: String {
        guard
            let locale = Locale.current.languageCode,
            let title = task.title[locale]
            else { return "" }
        return title
    }

    var hint: String {
        guard
            let locale = Locale.current.languageCode,
            let hint = task.hint[locale]
            else { return "" }
        return hint
    }

    var duration: String {
        guard let start = start, let end = end else {
            return ""
        }
        
        let duration = end.timeIntervalSince1970 - start.timeIntervalSince1970
        var components = DateComponents()
        let time = task.completionTime - Int(duration)

        guard time > 0 else {
            return ""
        }

        components.second = time
        return formatter.string(from: components) ?? ""
    }

    var type: TaskType {
        return task.taskType
    }

    let task: Task

    private let formatter: DateComponentsFormatter
    private var cancellable: AnyCancellable?
    private var start: Date?
    
    @Published private(set) var end: Date?
    
    init(task: Task) {
        self.task = task
        formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.second, .minute, .hour]
    }

    func startTimer() {
        guard task.completionTime > 0 else {
            return
        }
        
        start = Date()
        cancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] in self?.end = $0 }
    }

    func stopTimer() {
        cancellable?.cancel()
    }

    var isRespectingTime: Bool {
        guard let start = start, let end = end else {
            return false
        }

        return Int(end.timeIntervalSince1970 - start.timeIntervalSince1970) <= task.completionTime
    }
}
