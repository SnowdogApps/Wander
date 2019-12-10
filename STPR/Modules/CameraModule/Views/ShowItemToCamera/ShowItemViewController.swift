//
//  ShowItemToCameraViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/30/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Vision
import UIKit

protocol ShowItemTaskDelegate: AnyObject {
    func userDidShowedItem()
}

final class ShowItemViewController: UIViewController {
    private let showItemData: ShowItemToCameraData

    weak var delegate: ShowItemTaskDelegate?

    init(showItemData: ShowItemToCameraData) {
        self.showItemData = showItemData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraController()
    }

    private func setupCameraController() {
        let arVC = ARViewController(configuration: .imageClassiffication(model: MobileNetV2().model))
        arVC.delegate = self
        addChild(arVC, to: view)
    }
}

extension ShowItemViewController: ARViewControllerDelegate {
    func imageClassified(with observations: [VNClassificationObservation]) {
        let accepted = observations
            .filter { Double($0.confidence) > showItemData.acceptThreshold }
            .map { $0.identifier }

        guard !Set(accepted).intersection(showItemData.modelClasses).isEmpty else {
            return
        }

        delegate?.userDidShowedItem()
    }
}
