//
//  CameraCoordinator.swift
//  STPR
//
//  Created by Artur Chabera on 08/11/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import Combine

protocol CameraCoordinatorDelegate: NSObject {
    func open(module index: Coordinator.ModuleIndex)
    func presentDetailsController(task: Task)
    func presentQuestionController(task: Task, session: TaskSessionController)
    func presentMissionSummaryController(modelController: MissionSessionModelController)
}

class CameraCoordinatorController: Coordinator {

    private let dependencies: Dependencies
    private let userExperienceManager: UserExperienceManager

    private let navigation = NavigationController()
    private let navigationBar = NavBarController()
    private var cancellables: Set<AnyCancellable> = []

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.userExperienceManager = dependencies.userExperienceManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: \(aDecoder) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.delegate = delegate
        addChild(navigationBar, to: view)
        navigationBar.add(rootController: navigation)
        navigationBar.composeMailAction = { [weak self] in
            self?.composeMail()
        }

        let modelController = CameraModelController(dependencies: dependencies)
        let cameraController = CameraViewController(modelController: modelController)
        cameraController.delegate = self
        navigation.addChild(cameraController, to: navigation.view)
        bindExpBar()
    }

    private func bindExpBar() {
        userExperienceManager
            .$userExperience
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink { [weak self] userExperience in
                guard let userExperience = userExperience else { return }
                self?.navigationBar.update(userExperience: userExperience)
        }.store(in: &cancellables)
    }
}

extension CameraCoordinatorController: TaskPresentable { }

extension CameraCoordinatorController: CameraCoordinatorDelegate {
    func presentDetailsController(task: Task) {
        presentDetails(task: task)
    }

    func presentQuestionController(task: Task, session: TaskSessionController) {
        presentQuestion(task: task, sessionController: session)
    }

    func open(module index: Coordinator.ModuleIndex) {
        openModule(index)
    }

    func presentMissionSummaryController(modelController: MissionSessionModelController) {
        DispatchQueue.main.async {
            let missionSummaryVC = MissionSummaryViewController(modelController: modelController)
            self.navigation.present(missionSummaryVC, animated: true)
        }
    }
}
