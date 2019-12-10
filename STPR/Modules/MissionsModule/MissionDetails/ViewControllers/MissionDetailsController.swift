//
//  MissionDetailsController.swift
//  STPR
//
//  Created by Artur Chabera on 02/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import Combine

protocol MissionDetailsDelegate: NSObject {
    func selected(_ task: Task)
}

class MissionDetailsController: StackViewController {
    enum MissionState {
        case start, active
    }

    enum Layout {
        static let buttonMargin: CGFloat = 16.0
        static let buttonHeight: CGFloat = 48.0
    }

    weak var delegate: MissionCoordinatorDelegate?

    private let modelController: MissionDetailsModelController
    private var startMissionButton: UIButton!
    private var cancellables: Set<AnyCancellable> = []
    private var missionState: MissionState = .start
    private let impactGenerator = UIImpactFeedbackGenerator(style: .rigid)

    init(modelController: MissionDetailsModelController) {
        self.modelController = modelController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupUI()
        bindViewMode()
        impactGenerator.prepare()
    }

    private func setupUI() {
        let singleMissionViewModel = modelController.makeSingeMissionViewModel()
        let descriptionSubController = MissionDescriptionSubController(modelController: modelController)
        descriptionSubController.delegate = delegate
        add(descriptionSubController)

        let tasksSubController = MissionTasksSubController(viewModel: modelController)
        tasksSubController.delegate = self
        add(tasksSubController)

        startMissionButton = UIButton(type: .system)
        startMissionButton.addTarget(self, action: #selector(startMission(_:)), for: .touchUpInside)
        startMissionButton.setTitleColor(.appBackground, for: .normal)
        startMissionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        startMissionButton.layer.cornerRadius = Layout.buttonHeight / 2
        view.addSubview(startMissionButton)
        startMissionButton.layer.zPosition = .greatestFiniteMagnitude
        startMissionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startMissionButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -Layout.buttonMargin),
            startMissionButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: Layout.buttonHeight),
            startMissionButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -Layout.buttonHeight),
            startMissionButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight)
        ])
    }

    private func bindViewMode() {
        modelController.fetch()

        modelController
            .$userSession
            .receive(on: RunLoop.main)
            .sink { [weak self] userSession in
                let taskActive = !(userSession?.activeTaskId.isEmpty ?? true)
                (self?.navigationController as? NavigationController)?.backButton.isHidden = taskActive
                (self?.navigationController as? NavigationController)?.interactivePopGestureRecognizer?.isEnabled = !taskActive
                self?.missionState = taskActive ? .active : .start
                self?.styleButton()
        }.store(in: &cancellables)

        modelController
            .$missionFinished
            .receive(on: RunLoop.main)
            .sink { [weak self] success in
                guard success else { return }
                self?.modelController.abandonMission()
                self?.presentMissionAlreadyFinishedAlert()
        }.store(in: &cancellables)
    }

    private func styleButton() {
        switch missionState {
        case .start:
            startMissionButton.setTitle("startMission".localized(), for: .normal)
            startMissionButton.backgroundColor = .appGreen
        case .active:
            startMissionButton.setTitle("abandon".localized(), for: .normal)
            startMissionButton.backgroundColor = .appRed
        }
    }

    @objc private func startMission(_ sender: UIButton) {
        impactGenerator.impactOccurred()
        switch missionState {
        case .active:
            modelController.abandonMission()
            delegate?.backToRoot()
        case .start:
            modelController.startMission()
            openMissionTab()
        }
    }

    private func openMissionTab() {
        modelController
            .$activeTask
            .first { $0 != nil }
            .compactMap { $0 }
            .sink { [weak self] task in
                switch task.taskType {
                case .collectItems, .goToLocation, .leaveLocation:
                    self?.delegate?.openMaps()
                case .scanMarker, .showItemToCamera, .question:
                    self?.delegate?.openCamera()
                default: break}
        }.store(in: &cancellables)
    }

    private func presentMissionAlreadyFinishedAlert() {
        let backAction = AlertViewController.Action(
            title: "back".localized(),
            style: .plain,
            handler: { [weak self] _ in self?.delegate?.backToRoot() }
        )

        let configuration = AlertViewController.Configuration(
            image: UIImage(systemName: "hand.raised"),
            title: "missionFinishedTitle".localized(),
            subhead: "missionFinishedSubtitle".localized(),
            actions: [backAction]
        )

        let alert = AlertViewController(configuration: configuration)
        PopupPresenter(contentViewController: alert)
            .present(in: self, completion: nil)
    }
}

extension MissionDetailsController: MissionDetailsDelegate {
    func selected(_ task: Task) {
        let taskHint = TaskHintViewController(viewModel: .init(task: task, session: nil))
        PopupPresenter(contentViewController: taskHint)
            .present(in: self, completion: nil)
    }
}
