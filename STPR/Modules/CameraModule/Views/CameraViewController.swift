//
//  CameraViewController.swift
//  STPR
//
//  Created by Artur Chabera on 08/11/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import Combine
import Vision
import ARKit

class CameraViewController: UIViewController {

    private let hintView = HintView()
    private let modelController: CameraModelController
    weak var delegate: CameraCoordinatorDelegate?

    private var cancellables: Set<AnyCancellable> = []

    init(modelController: CameraModelController) {
        self.modelController = modelController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("\(coder) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindModelController()
        modelController.fetch()
        modelController.setFinishedMissionListener()
        setupFlashlight()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupHintUI()
    }

    private func bindModelController() {
        modelController
            .$task
            .receive(on: DispatchQueue.main)
            .replaceError(with: nil)
            .sink { [weak self] (task) in
                self?.refreshHintUI(with: task)
                self?.setupCamera(for: task)
        }.store(in: &cancellables)

        modelController
            .$missionFinished
            .receive(on: DispatchQueue.main)
            .replaceError(with: false)
            .sink { [weak self] (missionFinished) in
                guard
                    (missionFinished ?? false),
                    let modelController = self?.modelController.makeMissionSessionModelController()
                    else { return }
                self?.delegate?.presentMissionSummaryController(modelController: modelController)
        }.store(in: &cancellables)
    }

    private func setupHintUI() {
        hintView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintView)
        NSLayoutConstraint.activate([
            hintView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hintView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hintView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            hintView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    private func refreshHintUI(with task: Task?) {
        let singleTaskModel = modelController.makeSingleTaskViewModel(task: task, session: nil)
        hintView.icon = singleTaskModel?.taskType.icon ?? .exclamation
        hintView.title = singleTaskModel?.title ?? "selectMissionTitle".localized()
        hintView.body = singleTaskModel?.hint ?? "selectMissionSubtitle".localized()
        hintView.action = { [weak self] in
            guard let self = self else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if let task = task {
                switch task.taskType {
                case .goToLocation, .leaveLocation, .collectItems:
                    self.delegate?.open(module: .map)
                case .scanMarker, .showItemToCamera:
                    self.delegate?.presentDetailsController(task: task)
                case .question:
                    self.delegate?.presentQuestionController(
                        task: task,
                        session: self.modelController.getTaskSessionController())
                case .selectPath: break
                }
            } else {
                self.delegate?.open(module: .missions)
            }
        }
    }

    private func setupCamera(for task: Task?) {
        children.forEach {
            removeChild($0)
        }
        switch task?.taskType {
        case .showItemToCamera:
            let arCameraViewController = ARViewController(configuration: .imageClassiffication(model: MobileNetV2().model))
            arCameraViewController.delegate = self
            addChild(arCameraViewController, to: view)
        case .scanMarker:
            guard let model = modelController.makeScanMarkerModelController() else { return }
            let scanController = ScanMarkerController(modelController: model)
            scanController.delegate = self
            addChild(scanController, to: view)
        default:
            let arCameraViewController = ARViewController(configuration: .liveView)
            arCameraViewController.delegate = self
            addChild(arCameraViewController, to: view)
        }
    }

    private func setupFlashlight() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleTorch))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }

    @objc func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

        try? device.lockForConfiguration()
        if device.torchMode == .off {
            device.torchMode = .on
        } else {
            device.torchMode = .off
        }

        device.unlockForConfiguration()
    }
}

extension CameraViewController: ARViewControllerDelegate {
    func imageClassified(with observations: [VNClassificationObservation]) {
        guard let showItemData = modelController.task?.showItemToCamera else { return }
        let accepted = observations
            .filter { Double($0.confidence) > showItemData.acceptThreshold }
            .map { $0.identifier }
            .compactMap { substring -> [String] in
               return substring
                   .replacingOccurrences(of: ",", with: "")
                   .split(separator: " ")
                   .compactMap { String($0) }
            }
            .flatMap { $0 }

            guard !Set(accepted).intersection(showItemData.modelClasses).isEmpty else { return }

            guard
                let task = modelController.task,
                task.taskType == .showItemToCamera
                else { return }

        DispatchQueue.main.async {
            let popup = AlertViewController.makeSuccessAlert(for: task) { [weak self] in
                self?.modelController.getTaskSessionController().finish(task: task)
            }
            self.present(alertController: popup)
        }
    }

    func imageTracked() {
        guard
            let task = modelController.task,
            task.taskType == .scanMarker
            else { return }

        DispatchQueue.main.async {
            let popup = AlertViewController.makeSuccessAlert(for: task) { [weak self] in
                self?.modelController.getTaskSessionController().finish(task: task)
            }
            self.present(alertController: popup)
        }
    }
}
