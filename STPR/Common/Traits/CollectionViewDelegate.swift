//
//  CollectionViewDelegate.swift
//  STPR
//
//  Created by Artur Chabera on 17/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

typealias ReusableCollectionViewDelegate = NSObject & UICollectionViewDelegate

class CollectionViewDelegate: ReusableCollectionViewDelegate {
    typealias Action = (Int) -> Void

    private let action: Action

    init(action: @escaping Action) {
        self.action = action
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        action(indexPath.row)
    }
}
