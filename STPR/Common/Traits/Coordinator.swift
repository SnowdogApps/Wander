//
//  Coordinator.swift
//  STPR
//
//  Created by Artur Chabera on 21/10/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit
import MessageUI

class Coordinator: UIViewController {
    enum ModuleIndex: Int {
        case missions = 1
        case camera = 2
        case map = 3
    }

    weak var delegate: AppCoordinatorDelegate?

    func openModule( _ moduleIndex: ModuleIndex) {
        delegate?.openTab(moduleIndex.rawValue)
    }

    func composeMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["galileo@wanderapp.eu"])
            mail.setSubject("Wander App - Creator Insights")
            mail.setMessageBody("<p>Hey I have a great idea for a tour!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            present(alertController: .make(title: "mailComposerError".localized(), image: UIImage(named: "logo")))
        }
    }
}

extension Coordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
