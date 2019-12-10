//
//  UIViewController.swift
//  STPR
//
//  Created by Artur Chabera on 12/02/2019.
//  Copyright © 2019 Artur Chabera. All rights reserved.
//

import UIKit

extension UIViewController {
    func addChild(_ controller: UIViewController, to container: UIView) {
        guard let subView = controller.view else { return }
        addChild(controller)
        container.addSubview(subView)
        controller.didMove(toParent: self)
        subView.fit(to: container)
        container.clipsToBounds = true
    }

    func removeChild(_ controller: UIViewController) {
        guard controller.parent != nil else {
            return
        }

        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }

    func present(alertController: AlertViewController, completion: (() -> Void)? = nil) {
        PopupPresenter(contentViewController: alertController)
            .present(in: self, completion: completion)
    }

    func presentError(_ error: Error, retry: @escaping () -> Void = {}) {
        present(alertController: .makeErrorAlert(for: error, retry: retry))
    }
}
