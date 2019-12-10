//
//  QuestionPresentable.swift
//  STPR
//
//  Created by Artur Chabera on 18/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

protocol TaskPresentable {
    func presentQuestion(task: Task, sessionController: TaskSessionController)
    func presentDetails(task: Task)
}

extension TaskPresentable where Self: UIViewController {
    func presentQuestion(task: Task, sessionController: TaskSessionController) {
        let questionController = QuestionViewController(task: task)
        questionController.action = { [weak self] in
            DispatchQueue.main.async {
                let alert = AlertViewController.makeSuccessAlert(for: task) {
                    sessionController.finish(task: task)
                }
                self?.present(alertController: alert, completion: nil)
            }
        }
        questionController.modalPresentationStyle = .overCurrentContext
        questionController.isModalInPresentation = true
        UIApplication.topViewController()?.present(questionController, animated: false)
    }

    func presentDetails(task: Task) {
        let taskHint = TaskHintViewController(viewModel: .init(task: task, session: nil))
        PopupPresenter(contentViewController: taskHint)
            .present(in: self, completion: nil)
    }
}
