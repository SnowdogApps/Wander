//
//  MissionsController.swift
//  STPR
//
//  Created by Artur Chabera on 02/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Combine
import UIKit
import CoreLocation

class MissionsController: UIViewController {
    private enum Layout {
        static var itemHeight: CGFloat {
            return UIScreen.main.bounds.height / 2.5
        }
    }

    @Published var location: CLLocation? = nil
    
    weak var delegate: MissionCoordinatorDelegate?
    private let modelController: MissionsModelController
    private let locationManager: CLLocationManager
    private var cancellables: Set<AnyCancellable> = []
    private var collectionView: UICollectionView!
    private var dataSource: CollectionViewDataSource<MissionCell, Mission>!
    private var collectionDelegate: CollectionViewDelegate!

    init(modelController: MissionsModelController) {
        self.modelController = modelController
        self.locationManager = CLLocationManager()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindModelController()
        locationManager.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        modelController.fetch()
    }

    private func setupUI() {
        view.backgroundColor = .appBackground

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeMissionLayout())
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = nil
        view.addSubview(collectionView)
        collectionView.fit(to: view)

        collectionView.register(MissionCell.self)
        collectionDelegate = CollectionViewDelegate { [weak self] (index) in
            guard let self = self else { return }
            let mission = self.modelController.missions[index]
            self.delegate?.startDetails(for: mission)
        }
        collectionView.delegate = collectionDelegate
    }

    private func bindModelController() {
        Publishers
            .CombineLatest3(modelController.$missions, $location, modelController.$completed)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (missions, location, completed) in
                guard let self = self,
                    let location = location
                    else { return }
                self.bindCollectionView(to: missions, location: location, with: completed)
        }.store(in: &cancellables)
    }

    private func bindCollectionView(to missions: [Mission], location: CLLocation, with completed: [String]) {
        dataSource = CollectionViewDataSource<MissionCell, Mission>(models: missions) { (mission, cell) in
            let distance = self.distanceToStart(mission, from: location)
            cell.missionModel = self.modelController.makeSingleMissionModelController(
                for: mission,
                distance: distance,
                isCompleted: completed.contains(mission.id))
        }

        collectionView.dataSource = dataSource
    }

    private func makeMissionLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Layout.itemHeight)
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func distanceToStart(_ mission: Mission, from location: CLLocation) -> Double {
        let latitude = mission.tasks.first?.latitude ?? 0.0
        let longitude = mission.tasks.first?.longitude ?? 0.0

        return CLLocation(latitude: latitude, longitude: longitude).distance(from: location)
    }
}

extension MissionsController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        manager.stopUpdatingLocation()
    }
}
