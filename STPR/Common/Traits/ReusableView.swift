//
//  ReusableView.swift
//  STPR
//
//  Created by Artur Chabera on 22/03/2019.
//  Copyright © 2019 Artur Chabera. All rights reserved.
//

import UIKit

protocol ReusableView: class {}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

protocol NibLoadableView: class {}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }

    func setupXib(_ autoresizingOptions: UIView.AutoresizingMask = [.flexibleWidth, .flexibleHeight]) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: Self.nibName, bundle: bundle)
        let views = nib.instantiate(withOwner: self, options: nil)
        guard let view = views.first as? UIView else { return }

        view.frame = self.bounds
        view.autoresizingMask = autoresizingOptions

        self.addSubview(view)
    }
}

typealias NibReusableView = NibLoadableView & ReusableView
