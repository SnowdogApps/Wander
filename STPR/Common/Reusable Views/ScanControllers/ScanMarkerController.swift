//
//  ScanMarkerViewController.swift
//  STPR
//
//  Created by Artur Chabera on 18/11/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import Vision
import ARKit
import Combine

final class ScanMarkerController: UIViewController {
    private let modelController: ScanMarkerModelController
    private var cancellables: Set<AnyCancellable> = []

    weak var delegate: ARViewControllerDelegate?

    init(modelController: ScanMarkerModelController) {
        self.modelController = modelController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindModelController()
        modelController.fetch()
    }

    private func bindModelController() {
        if modelController.scanMarkerData.videoUrl != nil {
            modelController
                .$marker
                .compactMap { $0 }
                .timeout(10, scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case let .failure(error) = completion {
                        self.presentError(error, retry: self.modelController.fetch)
                    }
                }) { [weak self] image in
                    guard let self = self else { return }
                    self.setupScanMarkerCameraController(using: image)
            }.store(in: &cancellables)
        } else {
            Publishers
                .Zip(modelController.$marker, modelController.$overlay)
                .compactMap { $0.0 }
                .timeout(10, scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    if case let .failure(error) = completion {
                        self.presentError(error, retry: self.modelController.fetch)
                    }
                }) { [weak self] image in
                    guard let self = self else { return }
                    self.setupScanMarkerCameraController(using: image)
            }.store(in: &cancellables)
        }
    }

    private func setupScanMarkerCameraController(using marker: CGImage) {
        children.forEach {
            if let cameraController = $0 as? ARViewController {
                cameraController.stopSession()
                removeChild(cameraController)
            }
        }

        let width = CGFloat(modelController.scanMarkerData.width)
        let imageReference = ARReferenceImage(marker, orientation: .up, physicalWidth: width)
        let cameraController = ARViewController(configuration: .imageTracking(images: [imageReference]))
        cameraController.overlay = modelController.overlay
        cameraController.delegate = delegate
        addChild(cameraController, to: view)
        cameraController.startSession()
    }
}
