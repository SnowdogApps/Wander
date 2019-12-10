//
//  ProfileNavBarController.swift
//  STPR
//
//  Created by Artur Chabera on 03/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class ProfileNavBarController: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var navigationBarContainer: UIView!
    @IBOutlet weak var navigationViewContainer: UIView!

    weak var delegate: AppCoordinatorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        //setup UI here
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shadowSize: CGFloat = 10
        let contactRect = CGRect(
            x: -shadowSize,
            y: navigationBarContainer.frame.height - shadowSize / 2,
            width: navigationBarContainer.frame.width + shadowSize * 2,
            height: shadowSize
        )
        navigationBarContainer.layer.shadowPath = UIBezierPath(rect: contactRect).cgPath
        navigationBarContainer.layer.shadowRadius = 5
        navigationBarContainer.layer.shadowOpacity = 0.4
        navigationBarContainer.layer.shadowColor = UIColor.darkGray.cgColor
        navigationBarContainer.layer.zPosition = .greatestFiniteMagnitude
    }
    
    func add(rootController: NavigationController) {
        addChild(rootController, to: navigationViewContainer)
    }

    @IBAction func openSettings(_ sender: UIButton) {
    }
    
}
