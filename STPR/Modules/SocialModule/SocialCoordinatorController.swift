//
//  SocialCoordinatorController.swift
//  STPR
//
//  Created by Artur Chabera on 27/08/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class SocialCoordinatorController: Coordinator {
    private let dependencies: Dependencies
    
    private let navigation = NavigationController()
    private let navigationBar = NavBarController()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder: \(aDecoder) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.delegate = delegate
        addChild(navigationBar, to: view)
        navigationBar.add(rootController: navigation)
        navigationBar.composeMailAction = { [weak self] in
            self?.composeMail()
        }
    }
}
