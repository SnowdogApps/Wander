//
//  ProfileCoordinatorController.swift
//  STPR
//
//  Created by Artur Chabera on 27/08/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class ProfileCoordinatorController: Coordinator {
    private let dependencies: Dependencies
    
    private let navigation = NavigationController()
    private let navigationBar = ProfileNavBarController()
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
        
        addChild(navigationBar, to: view)
        navigationBar.add(rootController: navigation)
        navigationBar.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: \(aDecoder) has not been implemented")
    }
}
