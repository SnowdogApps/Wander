//
//  OnboardingPageViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 8/30/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var headlineLabel: UILabel!
    @IBOutlet private weak var subheadlineLabel: UILabel!

    var page: OnboardingPage? {
        didSet {
            bindUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }

    private func bindUI() {
        guard let page = page, isViewLoaded else {
            return
        }

        headlineLabel.text = page.title
        subheadlineLabel.text = page.content
        imageView.image = page.image.flatMap { UIImage(named: $0) }
    }
}
