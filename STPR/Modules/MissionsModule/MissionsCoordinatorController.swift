//
//  MissionsCoordinatorController.swift
//  STPR
//
//  Created by Artur Chabera on 27/08/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Combine
import UIKit
import Combine

protocol MissionCoordinatorDelegate: class {
    func startDetails(for mission: Mission)
    func startDescription(for model: SingleMissionViewModel)
    func backToRoot()
    func openCamera()
    func openMaps()
}

class MissionsCoordinatorController: Coordinator {
    private let dependencies: Dependencies
    
    private let navigation = NavigationController()
    private let navigationBar = NavBarController()
    private var cancellables: Set<AnyCancellable> = []
    private let userExperienceManager: UserExperienceManager

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

        let missionsModelController = MissionsModelController(dependencies: dependencies)
        let viewController = MissionsController(modelController: missionsModelController)
        viewController.delegate = self
        navigation.pushViewController(viewController, animated: false)
        bindExpBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startActiveMission()
    }

    private func startActiveMission() {
        guard let userId = GlobalSettings.userId else {
            return
        }

        dependencies.userManager
            .sessionPublisher(userId: userId)
            .compactMap { $0 }
            .flatMap { session in
                self.dependencies.missionsManager
                    .missionPublisher()
                    .map { $0.first { $0.id == session.activeMissionId } }
        }
        .compactMap { $0 }
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else {
                    return
                }

                if case let .failure(error) = completion {
                    self.presentError(error, retry: self.startActiveMission)
                }
            }, receiveValue: { mission in
                self.navigation.popToRootViewController(animated: false)
                let modelController = MissionDetailsModelController(dependencies: self.dependencies, mission: mission)
                let viewController = MissionDetailsController(modelController: modelController)
                viewController.delegate = self
                self.navigation.pushViewController(viewController, animated: false)
            }
        ).store(in: &cancellables)
    }

    private func startMissions() {
        let missionsModelController = MissionsModelController(dependencies: dependencies)
        let viewController = MissionsController(modelController: missionsModelController)
        viewController.delegate = self
        navigation.show(viewController, sender: self)
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

extension MissionsCoordinatorController: MissionCoordinatorDelegate {
    func startDetails(for mission: Mission) {
        let modelController = MissionDetailsModelController(dependencies: dependencies, mission: mission)
        let viewController = MissionDetailsController(modelController: modelController)
        viewController.delegate = self
        navigation.show(viewController, sender: self)
    }

    func startDescription(for model: SingleMissionViewModel) {
        let viewController = MissionDetailsStoryViewController(viewModel: model)
        navigation.show(viewController, sender: self)
    }

    func backToRoot() {
        navigation.popToRootViewController(animated: true)
    }

    func openCamera() {
        openModule(.camera)
    }

    func openMaps() {
        openModule(.map)
    }
}
