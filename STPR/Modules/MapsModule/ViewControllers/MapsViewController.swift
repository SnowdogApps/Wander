//
//  MapsViewController.swift
//  STPR
//
//  Created by Artur Chabera on 30/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import Combine
import GoogleMaps

class MapsViewController: UIViewController {
    enum Layout {
        static let zoom: Float = 15.0
        static let hintTopSpacing: CGFloat = -8.0
        static let userIconWidth: CGFloat = 48.0
    }

    @IBOutlet weak var mapView: GMSMapView!
    private let modelController: MapsModelControlelr
    private let locationManager: CLLocationManager!
    private let hintView = HintView()
    private var cancellables: Set<AnyCancellable> = []
    private var userView: UserMapIcon!
    private let userMarker = GMSMarker()
    private var cameraCenteredOnUser = false

    private var region: CLCircularRegion?

    weak var delegate: MapsCoordinatorDelegate?

    init(modelController: MapsModelControlelr) {
        self.modelController = modelController
        self.locationManager = CLLocationManager()
        super.init(
            nibName: String(describing: MapsViewController.self),
            bundle: nil
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupHintUI()
        bindModelController()

        modelController.fetchTask()
    }

    private func setupUI() {
        guard
            let styleURL = Bundle.main.url(forResource: "defaultMapStyle", withExtension: "json")
            else { fatalError("Unable to load JSON") }
        mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.consumesGesturesInView = false

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()

        userView = UserMapIcon(frame: CGRect(origin: .zero, size: CGSize(width: Layout.userIconWidth, height: Layout.userIconWidth)))
        userMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        userMarker.iconView = userView
    }

    private func bindModelController() {
        modelController
            .$activeTask
            .replaceError(with: nil)
            .sink { [unowned self] task in
                self.updateView(with: task)
                self.setup(task)
        }.store(in: &cancellables)

        Publishers
            .CombineLatest(modelController.$availableMissions, modelController.$activeTask)
            .replaceError(with: ([], nil))
            .sink { [unowned self] (missions, activeTask) in
                self.mapView.clear()
                self.userMarker.map = self.mapView
                self.updateMarkers(with: missions, activeTask: activeTask)
        }.store(in: &cancellables)
    }

    private func updateView(with task: Task?) {
        guard let task = task else {
            resetHintData()
            return
        }
        let viewModel = modelController.makeTaskViewModel(for: task)
        hintView.icon = viewModel.taskType.icon
        hintView.title = viewModel.title
        hintView.body = viewModel.hint
        hintView.isUserInteractionEnabled = true
        hintView.action = { [weak self] in
            guard let self = self else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            switch task.taskType {
            case .goToLocation, .leaveLocation, .collectItems:
                guard let coordinate = self.locationManager.location?.coordinate else { return }
                self.moveCamera(to: coordinate.latitude, longitude: coordinate.longitude)
            case .scanMarker, .showItemToCamera:
                self.delegate?.openCamera()
            case .question:
                self.presentQuestion(task: task, sessionController: self.modelController.taskSessionController)
            default: break
            }
        }
    }

    private func resetHintData() {
        hintView.icon = .exclamation
        hintView.title = "selectMissionTitle".localized()
        hintView.body = "selectMissionSubtitle".localized()
        hintView.action = { [weak self] in
            guard let self = self else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            self.delegate?.openMissions()
        }
    }

    private func setupHintUI() {
        hintView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(hintView)
        NSLayoutConstraint.activate([
            hintView.leadingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.leadingAnchor),
            hintView.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor),
            hintView.topAnchor.constraint(equalTo: mapView.layoutMarginsGuide.topAnchor, constant: Layout.hintTopSpacing),
            hintView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    private func updateMarkers(with mission: [Mission], activeTask: Task?) {
        func styleMarker(with icon: UIFont.Icon, latitude: Double, longitude: Double, tag: Int? = nil) {
            let marker = GMSMarker()
            let markerImage: UIImage = icon.image(
                color: .appYellow,
                size: CGSize(width: 16, height: 25)
            )

            marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            let markerView = UIImageView(image: markerImage)
            markerView.tintColor = .appYellow
            marker.iconView = markerView
            marker.map = mapView
            guard let tag = tag else { return }
            marker.userData = GoogleMapsMarker(tag)
        }

        for mission in mission.enumerated() {
            styleMarker(
                with: .exclamation,
                latitude: mission.element.tasks[0].latitude,
                longitude: mission.element.tasks[0].longitude,
                tag: mission.offset
            )
        }

        guard let task = activeTask else { return }
        styleMarker(with: .question, latitude: task.latitude, longitude: task.longitude)
    }

    private func presentAvailableMission(for index: Int) {
        setActivityStatus(.visible(text: nil))
        let mission = modelController.availableMissions[index]
        modelController
            .fetchImage(from: mission.backgroundUrl)
            .replaceError(with: UIImage(named: "logo")!)
            .sink { [unowned self] image in
                self.setActivityStatus(.hidden)
                self.presentAlert(
                    with: image,
                    for: self.modelController.makeMissionViewModel(for: mission)
                )
        }.store(in: &cancellables)
    }

    private func presentAlert(with image: UIImage, for mission: SingleMissionViewModel) {
        let configuration = AlertViewController.Configuration(
            image: image,
            title: mission.title,
            subhead: mission.missionDescription,
            actions: []
        )
        
        let alert = AlertViewController(configuration: configuration)
        PopupPresenter(contentViewController: alert)
            .present(in: self, completion: nil)
    }

    private func presentTaskCompletedAlert(completion: @escaping () -> Void) {
        guard let task = modelController.activeTask else { return }
        let alert = AlertViewController.makeSuccessAlert(for: task) {
            completion()
        }
        present(alertController: alert, completion: nil)
    }

    private func setup(_ task: Task?) {
        guard let task = task else { return }
        switch task.taskType {
        case .goToLocation: setupGoToLocation(task)
        default: break
        }
    }

    private func setupGoToLocation(_ task: Task) {
        let center = CLLocationCoordinate2D(
            latitude: task.goToLocationData?.latitude ?? 0.0,
            longitude: task.goToLocationData?.longitude ?? 0.0
        )
        region = CLCircularRegion(
            center: center,
            radius: task.goToLocationData?.detectionRadius ?? 0.0,
            identifier: task.id
        )

        hintView.action = { [weak self] in
            self?.moveCamera(to: task.latitude, longitude: task.longitude)
        }
    }

    private func moveCamera(to latitude: Double, longitude: Double, zoom: Float = Layout.zoom) {
        let camerPosition: GMSCameraPosition = .camera(
            withLatitude: latitude,
            longitude: longitude,
            zoom: zoom
        )
        mapView.animate(to: camerPosition)
    }
}

extension MapsViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let markerData = marker.userData as? GoogleMapsMarker else { return false }
        presentAvailableMission(for: markerData.tag)
        return true
    }
}

extension MapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        mapView.isMyLocationEnabled = true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userMarker.rotation = newHeading.trueHeading
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userMarker.position = location.coordinate

        if let region = region {
            if region.contains(location.coordinate) {
                DispatchQueue.main.async {
                    self.presentTaskCompletedAlert { [weak self] in
                        self?.modelController.finishTask()
                    }
                }
            }
        }

        guard !cameraCenteredOnUser else { return }
        moveCamera(to: location.coordinate.latitude, longitude: location.coordinate.longitude)
        cameraCenteredOnUser = true
    }
}

extension MapsViewController: ActivityPresentable, TaskPresentable { }
