//
//  QuestionViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/7/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

protocol QuestionTaskDelegate: AnyObject {
    func userAnsweredQuestion(isCorrect: Bool)
}

final class QuestionViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var iconLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var answersStack: UIStackView!

    private let questionTask: Task
    var action: () -> Void = { }
    weak var delegate: QuestionTaskDelegate?

    private let impactGenerator = UINotificationFeedbackGenerator()

    init(task: Task) {
        questionTask = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        impactGenerator.prepare()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.fadeIn()
    }

    private func setupUI() {
        view.alpha = 0

        addChild(EffectViewController(), to: view)
        view.bringSubviewToFront(containerView)
        containerView.backgroundColor = .appBackground
        containerView.layer.cornerRadius = 8
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePopup)))

        separatorView.backgroundColor = .tetrialyFont

        iconLabel.font = UIFont.iconFont(ofSize: 44)
        iconLabel.text = questionTask.taskType.icon.rawValue
        iconLabel.textColor = .appYellow

        guard
            let lang = Locale.autoupdatingCurrent.languageCode,
            let question = questionTask.questionData
            else { return }

        questionLabel.text = question.question[lang]
        let answers = question.multipleAnswerOptions[lang]

        answersStack.arrangedSubviews.forEach {
            answersStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        answers?.enumerated().forEach { index, answer in
            let button = BorderButton()
            button.setTitle(answer, for: .normal)
            button.addTarget(self, action: #selector(selectAnswer(sender:)), for: .touchUpInside)
            button.tag = index

            answersStack.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }

    @objc func selectAnswer(sender: UIButton) {
        let isCorrect = sender.tag == questionTask.questionData?.correctAnswer
        impactGenerator.notificationOccurred(isCorrect ? .success : .error)

        view.fadeOut { (_) in
            self.dismiss(animated: false)
            self.action()
        }
    }

    @objc private func closePopup() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        view.fadeOut { (_) in
            self.dismiss(animated: false)
        }
    }
}
