//
//  MissionDetailsStoryViewController.swift
//  STPR
//
//  Created by Artur Chabera on 25/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class MissionDetailsStoryViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    private let viewModel: SingleMissionViewModel

    init(viewModel: SingleMissionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .appBackground

        titleLabel.textColor = .mainFont
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)

        bodyLabel.textColor = .secondaryFont
        bodyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    private func bindViewModel() {
        viewModel.backgroundUrl.map { imageView.setImage(from: $0) }
        titleLabel.text = viewModel.title
        bodyLabel.text = viewModel.fullStory
    }
}
