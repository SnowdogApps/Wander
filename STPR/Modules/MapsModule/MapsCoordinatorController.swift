//
//  MapsCoordinatorController.swift
//  STPR
//
//  Created by Artur Chabera on 27/08/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import Combine

protocol MapsCoordinatorDelegate: AnyObject {
    func openCamera()
    func openMissions()
}

class MapsCoordinatorController: Coordinator {
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
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder: \(aDecoder) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.delegate = delegate
        addChild(navigationBar, to: view)
        navigationBar.add(rootController: navigation)
        navigationBar.composeMailAction = { [weak self] in
            self?.composeMail()
        }
        bindExpBar()
        start()
    }

    private func start() {
        let mapsModelController = MapsModelControlelr(dependencies: dependencies)
        let viewController = MapsViewController(modelController: mapsModelController)
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

extension MapsCoordinatorController: MapsCoordinatorDelegate {
    func openCamera() {
        openModule(.camera)
    }

    func openMissions() {
        openModule(.missions)
    }
}
