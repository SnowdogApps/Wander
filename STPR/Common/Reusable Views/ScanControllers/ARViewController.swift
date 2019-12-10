//
//  ViewController.swift
//  ARModule
//
//  Created by Majid Jabrayilov on 8/26/19.
//  Copyright © 2019 Majid Jabrayilov. All rights reserved.
//

import UIKit
import Vision
import ARKit

protocol ARViewControllerDelegate: AnyObject {
    func imageClassified(with observations: [VNClassificationObservation])
    func imageTracked()
}

extension ARViewControllerDelegate {
    func imageClassified(with observations: [VNClassificationObservation]) {}
    func imageTracked() {}
}

final class ARViewController: UIViewController {
    private let sceneView = ARSCNView()
    private let cameraAim = UIImageView(image: UIImage(named: "cameraHint"))
    private let shadowLayer = CAShapeLayer()
    private let configuration: Configuration
    weak var delegate: ARViewControllerDelegate?

    var overlay: CGImage?
    private let queue = DispatchQueue(label: "stpr.coreml.image")

    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        sceneView.session.delegate = self
        sceneView.delegate = self
        view.addSubview(sceneView)
        sceneView.fit(to: view)

        switch configuration {
        case .liveView:
            break
        default:
            setupCameraAim()
        }
    }

    private func setupCameraAim() {
        shadowLayer.opacity = 0.3
        shadowLayer.fillColor = UIColor.black.cgColor
        view.layer.addSublayer(shadowLayer)

        view.addSubview(cameraAim)
        cameraAim.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraAim.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cameraAim.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let path = UIBezierPath(rect: view.frame)
        path.append(UIBezierPath(roundedRect: cameraAim.frame, cornerRadius: 8).reversing())
        shadowLayer.path = path.cgPath
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    func configurationType() -> Configuration {
        return configuration
    }

    func startSession() {
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = self.configuration.trackingImages
        sceneView.session.run(configuration)
    }

    func stopSession() {
        sceneView.session.pause()
    }
}

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        queue.async {
            self.performImageClassification()
        }
    }
}

extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard
            let imageAnchor = anchor as? ARImageAnchor,
            let overlay = overlay
            else { return }

        let physicalWidth = imageAnchor.referenceImage.physicalSize.width
        let physicalHeight = imageAnchor.referenceImage.physicalSize.height

        let plane = SCNPlane(width: physicalWidth, height: physicalHeight)
        plane.firstMaterial?.diffuse.contents = overlay

        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -Float.pi / 2
        node.addChildNode(planeNode)

        delegate?.imageTracked()
    }
}

extension ARViewController {
    private func performImageClassification() {
        guard
            case let .imageClassiffication(model) = configuration,
            let request = try? VNCoreMLRequest(model: VNCoreMLModel(for: model)),
            let image = sceneView.session.currentFrame?.capturedImage
            else { return }

        request.imageCropAndScaleOption = .scaleFit
        let classification = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? classification.perform([request])

        if let observations = request.results as? [VNClassificationObservation] {
            delegate?.imageClassified(with: observations)
        }
    }
}

extension ARViewController {
    enum Configuration {
        case imageTracking(images: Set<ARReferenceImage>)
        case imageClassiffication(model: MLModel)
        case liveView

        var trackingImages: Set<ARReferenceImage> {
            switch self {
            case let .imageTracking(images): return images
            default: return Set()
            }
        }
    }
}
