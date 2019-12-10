//
//  ActivityIndicatorView.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/27/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIActivityIndicatorView {
    private struct Constants {
        static let margin: CGFloat = 16
        static let indicatorHeight: CGFloat = 37
    }

    private var startAnimatingTask: DispatchWorkItem?

    private lazy var loaderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = text
        label.sizeToFit()
        self.addSubview(label)
        return label
    }()

    var text: String = "" {
        didSet {
            loaderLabel.text = text
            loaderLabel.sizeToFit()
        }
    }

    init() {
        super.init(style: .large)
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
        hidesWhenStopped = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func superStartAnimating() {
        super.startAnimating()
    }

    override func startAnimating() {
        stopAnimating()

        startAnimatingTask = DispatchWorkItem { [weak self] in
            self?.superStartAnimating()
            self?.loaderLabel.isHidden = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: startAnimatingTask!)
    }

    override func stopAnimating() {
        if let task = startAnimatingTask {
            if !task.isCancelled {
                startAnimatingTask?.cancel()
            }
        }

        super.stopAnimating()

        if hidesWhenStopped {
            loaderLabel.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let convertedCenter = convert(center, from: superview)
        loaderLabel.center.x = convertedCenter.x
        loaderLabel.center.y = convertedCenter.y + (Constants.indicatorHeight / 2) + Constants.margin
    }
}
