//
//  NavigationController.swift
//  STPR
//
//  Created by Artur Chabera on 02/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    let backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        backButton.layer.cornerRadius = 20
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
                backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                backButton.heightAnchor.constraint(equalToConstant: 40),
                backButton.widthAnchor.constraint(equalToConstant: 40)
            ])
        
        backButton.isHidden = true
        backButton.titleLabel?.font = UIFont.iconFont(ofSize: 16)
        backButton.setTitle(UIFont.Icon.back.rawValue, for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(pop(_:)), for: .touchUpInside)
        
        delegate = self
        
        navigationBar.isHidden = true
    }
    
    @objc private func pop(_ sender: UIButton) {
        super.popViewController(animated: true)
    }
}

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let coordinator = navigationController.topViewController?.transitionCoordinator else { return }
        coordinator.notifyWhenInteractionChanges { (context) in
            guard !context.isCancelled else { return }
            self.backButton.isHidden = navigationController.children.count == 1 || viewController.navigationItem.hidesBackButton
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        backButton.isHidden = navigationController.children.count == 1 || viewController.navigationItem.hidesBackButton
    }
}
