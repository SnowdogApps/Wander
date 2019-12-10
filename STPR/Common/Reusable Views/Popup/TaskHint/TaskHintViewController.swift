//
//  TaskHintViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/15/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

final class TaskHintViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var timeIconLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!

    var viewModel: SingleTaskViewModel

    init(viewModel: SingleTaskViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .containerBackground
        viewModel.image.map { imageView.setImage(from: $0) }

        titleLabel.textColor = .mainFont
        titleLabel.text = viewModel.title

        subtitleLabel.textColor = .secondaryFont
        subtitleLabel.text = "task".localized()

        timeIconLabel.textColor = .secondaryFont
        timeIconLabel.font = UIFont.iconFont(ofSize: 12)
        timeIconLabel.text = UIFont.Icon.time.rawValue

        timeLabel.textColor = .mainFont
        timeLabel.text = viewModel.time

        bodyLabel.textColor = .secondaryFont
        bodyLabel.text = viewModel.story
    }
}
