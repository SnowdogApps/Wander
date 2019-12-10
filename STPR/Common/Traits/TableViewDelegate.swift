//
//  TableViewDelegate.swift
//  STPR
//
//  Created by Artur Chabera on 13/04/2019.
//  Copyright © 2019 Artur Chabera. All rights reserved.
//

import UIKit

typealias ReusableTableViewDelegate = NSObject & UITableViewDelegate

class TableViewDelegate: ReusableTableViewDelegate {
    typealias Action = (Int) -> Void

    private let action: Action

    init(action: @escaping Action) {
        self.action = action
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        action(indexPath.row)
    }
}
