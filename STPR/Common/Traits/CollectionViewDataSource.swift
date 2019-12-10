//
//  CollectionViewDataSource.swift
//  STPR
//
//  Created by Artur Chabera on 13/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

typealias ReusabeCollectionViewDataSource = NSObject & UICollectionViewDataSource
typealias ReusableCollectionViewCell = UICollectionViewCell & NibReusableView

class CollectionViewDataSource<Cell: ReusableCollectionViewCell, Model>: ReusabeCollectionViewDataSource {
    typealias CellConfigurator = (Model, Cell) -> Void

    private let models: [Model]
    private let cellConfigurator: CellConfigurator

    init(models: [Model], cellConfigurator: @escaping CellConfigurator) {
        self.models = models
        self.cellConfigurator = cellConfigurator
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueReusableCell(for: indexPath)
        let model = models[indexPath.row]
        cellConfigurator(model, cell)
        return cell
    }
}
