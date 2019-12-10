//
//  EffectViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/7/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

final class EffectViewController: UIViewController {
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.fit(to: view)
    }
}
