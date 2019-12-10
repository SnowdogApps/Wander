//
//  MissonSummaryViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/14/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit
import Combine

final class MissionSummaryViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private var cancellable: AnyCancellable?
    private let modelController: MissionSessionModelController

    init(modelController: MissionSessionModelController) {
        self.modelController = modelController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLookAndFeel()
        bindModelController()
        modelController.fetch()
    }

    private func bindModelController() {
        cancellable = modelController
            .$mission
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in self.tableView.reloadData() }
        )
    }

    private func setupLookAndFeel() {
        tableView.register(MissionSummaryCell.self)
        tableView.register(TaskSessionCell.self)
        tableView.dataSource = self
        tableView.backgroundColor = .appBackground
    }
}

extension MissionSummaryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section != 0 else {
            return 1
        }
        return modelController.taskSessionViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let summaryCell: MissionSummaryCell = tableView.dequeueReusableCell(for: indexPath)
            summaryCell.modelController = modelController
            return summaryCell
        } else {
            let cell: TaskSessionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.viewModel = modelController.taskSessionViewModels[indexPath.item]
            return cell
        }
    }
}
