//
//  TableViewDataSource.swift
//  STPR
//
//  Created by Artur Chabera on 12/04/2019.
//  Copyright © 2019 Artur Chabera. All rights reserved.
//

import UIKit

typealias ReusabeTableViewDataSource = NSObject & UITableViewDataSource
typealias ReusableTableViewCell = UITableViewCell & NibReusableView

class TableViewDataSource<Cell: ReusableTableViewCell, Model>: ReusabeTableViewDataSource {
    typealias CellConfigurator = (Model, Cell) -> Void

    private let models: [Model]
    private let cellConfigurator: CellConfigurator

    init(models: [Model], cellConfigurator: @escaping CellConfigurator) {
        self.models = models
        self.cellConfigurator = cellConfigurator
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(for: indexPath)
        let model = models[indexPath.row]
        cellConfigurator(model, cell)
        return cell
    }
}
