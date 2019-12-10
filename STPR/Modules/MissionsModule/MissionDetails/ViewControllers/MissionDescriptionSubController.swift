//
//  MissionDescriptionSubController.swift
//  STPR
//
//  Created by Artur Chabera on 18/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Combine
import UIKit

final class MissionDescriptionSubController: UIViewController {
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var coinsValueLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var verticalSeparatorView: UIView!
    @IBOutlet weak var expValueLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var horizontalSeparatorView: UIView!

    private let modelController: MissionDetailsModelController
    private let viewModel: SingleMissionViewModel
    private var cancellables: Set<AnyCancellable> = []

    weak var delegate: MissionCoordinatorDelegate?

    init(modelController: MissionDetailsModelController) {
        self.viewModel = modelController.makeSingeMissionViewModel()
        self.modelController = modelController

        super.init(
            nibName: String(describing: MissionDescriptionSubController.self),
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindModelController()
    }

    private func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        titleLabel.textColor = .mainFont

        cityLabel.textColor = .secondaryFont

        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timeLabel.textColor = .tetrialyFont
        timeLabel.text = "time".localized()

        timeValueLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        timeValueLabel.textColor = .mainFont

        coinsValueLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        coinsValueLabel.textColor = .mainFont

        coinsLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        coinsLabel.textColor = .tetrialyFont
        coinsLabel.text = "coins".localized()

        expValueLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        expValueLabel.textColor = .mainFont

        expLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        expLabel.textColor = .tetrialyFont
        expLabel.text = "exp".localized()

        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryFont

        verticalSeparatorView.backgroundColor = .tetrialyFont
        horizontalSeparatorView.backgroundColor = .tetrialyFont

        readMoreButton.setTitle("readMore".localized(), for: .normal)
        readMoreButton.setTitleColor(.mainFont, for: .normal)
        readMoreButton.setTitleColor(.secondaryFont, for: .highlighted)
        readMoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let iconLabel = UILabel()
        iconLabel.font = UIFont.iconFont(ofSize: 14)
        iconLabel.text = UIFont.Icon.chevronRight.rawValue
        iconLabel.textColor = .mainFont
        readMoreButton.addSubview(iconLabel)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconLabel.rightAnchor.constraint(equalTo: readMoreButton.rightAnchor, constant: -8),
            iconLabel.topAnchor.constraint(equalTo: readMoreButton.topAnchor),
            iconLabel.bottomAnchor.constraint(equalTo: readMoreButton.bottomAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 14)
        ])
    }

    private func bindModelController() {
        if let image = viewModel.backgroundUrl {
            backgroundImageView.setImage(from: image)
        }

        titleLabel.text = viewModel.title
        timeValueLabel.text = viewModel.time
        coinsValueLabel.text = viewModel.coins
        expValueLabel.text = viewModel.exp
        descriptionLabel.text = viewModel.missionDescription
        cityLabel.text = viewModel.city

        modelController.$progress
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { self.progressView.isHidden = $0 == 0 })
            .assign(to: \.progress, on: progressView)
            .store(in: &cancellables)
    }

    @IBAction func readMore(_ sender: UIButton) {
        delegate?.startDescription(for: viewModel)
    }
}
