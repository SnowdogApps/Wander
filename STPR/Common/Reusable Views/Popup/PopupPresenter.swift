//
//  PopupPresenter.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/10/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

final class PopupPresenter: UIViewController {
    private let contentView = UIView()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .soft)

    init(contentViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        addChild(contentViewController, to: contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLookAndFeel()
        setupContentView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.fadeIn()
        impactGenerator.prepare()
    }

    private func setupLookAndFeel() {
        addChild(EffectViewController(), to: view)
        view.alpha = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePopup)))
    }

    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .appBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.appBackground.cgColor
        contentView.layer.shadowOffset = .init(width: 1, height: 1)
        contentView.layer.shadowOpacity = 1
        view.addSubview(contentView)

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.9),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.25),
            contentView.heightAnchor.constraint(lessThanOrEqualTo: safeArea.heightAnchor, multiplier: 0.9),
            contentView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }

    @objc private func closePopup() {
        impactGenerator.impactOccurred()
        view.fadeOut { (_) in
            self.dismiss(animated: false)
        }
    }
}

extension PopupPresenter {
    func present(in viewController: UIViewController, completion: (() -> Void)?) {
        modalPresentationStyle = .overFullScreen
        viewController.present(self, animated: false, completion: completion)
    }
}
