//
//  MissionTasksSubController.swift
//  STPR
//
//  Created by Artur Chabera on 18/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import Combine

// TODO: refactor this screen by replacing child VC with single collection view
final class StiffCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

class MissionTasksSubController: UIViewController {
    private enum Layout {
        static let cellMargin: CGFloat = 4.0
        static let groupHeight: CGFloat = 64.0
    }

    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: MissionDetailsDelegate?
    private var dataSource: CollectionViewDataSource<SingleTaskCell, SingleTaskViewModel>!
    private var collectionViewDelegate: UICollectionViewDelegate!
    private let viewModel: MissionDetailsModelController
    private var cancellables: Set<AnyCancellable> = []
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)

    init(viewModel: MissionDetailsModelController) {
        self.viewModel = viewModel
        super.init(
            nibName: String(describing: MissionTasksSubController.self),
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        impactGenerator.prepare()
    }

    private func setupUI() {
        tasksLabel.textColor = .mainFont
        tasksLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)

        collectionView.register(SingleTaskCell.self)
        collectionView.backgroundView = nil
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout = makeLayout()
        bindDataSource()
        collectionViewDelegate = CollectionViewDelegate { [weak self] (index) in
            guard
                let self = self,
                let cell = self.collectionView
                    .cellForItem(at: IndexPath(item: index, section: 0)) as? SingleTaskCell
                else { return }
            self.delegate?.selected(cell.viewModel.task)
            self.impactGenerator.impactOccurred()
        }
        collectionView.delegate = collectionViewDelegate
        collectionView.isScrollEnabled = false
    }

    private func bindViewModel() {
        viewModel
            .$missionSession
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.bindDataSource() }
            .store(in: &cancellables)
    }

    private func bindDataSource() {
        let models = viewModel.makeTaskViewModels()
        dataSource = CollectionViewDataSource<SingleTaskCell, SingleTaskViewModel>(models: models) { (model, cell) in
            cell.viewModel = model
        }
        collectionView.dataSource = dataSource
    }

    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Layout.groupHeight)
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 2 * Layout.groupHeight, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
