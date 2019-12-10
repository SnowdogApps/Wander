//
//  UICollectionView.swift
//  STPR
//
//  Created by Artur Chabera on 21/03/2019.
//  Copyright © 2019 Artur Chabera. All rights reserved.
//

import UIKit

extension UICollectionView {
    enum SupplementaryViewKind: String {
        case header = "UICollectionElementKindSectionHeader"
        case footer = "UICollectionElementKindSectionFooter"
    }

    func register<T: UICollectionViewCell>(_: T.Type) where T: NibReusableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        guard
            let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as? T
            else { fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)") }
        return cell
    }

    func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind: SupplementaryViewKind) where T: NibReusableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: forSupplementaryViewOfKind.rawValue,
                 withReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueSupplementaryView<T: UICollectionReusableView>(ofKind: SupplementaryViewKind, for indexPath: IndexPath) -> T where T: ReusableView {
        guard
            let view = dequeueReusableSupplementaryView(ofKind: ofKind.rawValue,
                                                        withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T
            else { fatalError("Could not dequeue supplementary view with identifier: \(T.reuseIdentifier)") }
        return view
    }
}
