//
//  ActivityPresentable.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/27/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

enum ActivityStatus {
    case visible(text: String?)
    case hidden
}

protocol ActivityPresentable {
    func setActivityStatus(_ status: ActivityStatus)
}

extension ActivityPresentable where Self: UIViewController {

    func setActivityStatus(_ status: ActivityStatus) {
        defaultActivityStatus(status)
    }

    func defaultActivityStatus(_ status: ActivityStatus) {
        guard isViewLoaded else { return }
        switch status {
        case .hidden:
            findActivityIndicatorView()?.stopAnimating()
        case .visible(let text):
            if let activityIndicatorView = findActivityIndicatorView() {
                activityIndicatorView.startAnimating()
                activityIndicatorView.isHidden = false
                guard let text = text else { return }
                activityIndicatorView.text = text
            } else {
                let activityIndicatorView = ActivityIndicatorView()
                activityIndicatorView.backgroundColor = .clear
                view.addSubview(activityIndicatorView)
                setupConstraints(for: activityIndicatorView)
                activityIndicatorView.startAnimating()
                guard let text = text else { return }
                activityIndicatorView.text = text
            }
        }
    }

    private func setupConstraints(for activityIndicatorView: ActivityIndicatorView) {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func findActivityIndicatorView() -> ActivityIndicatorView? {
        return view.subviews.compactMap { $0 as? ActivityIndicatorView }.first
    }
}

extension ActivityPresentable where Self: UIView {
    func setActivityStatus(_ status: ActivityStatus) {
        defaultActivityStatus(status)
    }

    func defaultActivityStatus(_ status: ActivityStatus) {
        switch status {
        case .hidden:
            findActivityIndicatorView()?.stopAnimating()
        case .visible(let text):
            if let activityIndicatorView = findActivityIndicatorView() {
                activityIndicatorView.startAnimating()
                activityIndicatorView.isHidden = false
                guard let text = text else { return }
                activityIndicatorView.text = text
            } else {
                let activityIndicatorView = ActivityIndicatorView()
                addSubview(activityIndicatorView)
                setupConstraints(for: activityIndicatorView)
                activityIndicatorView.startAnimating()
                guard let text = text else { return }
                activityIndicatorView.text = text
            }
        }
    }

    private func setupConstraints(for activityIndicatorView: ActivityIndicatorView) {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            activityIndicatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func findActivityIndicatorView() -> ActivityIndicatorView? {
        return subviews.compactMap { $0 as? ActivityIndicatorView }.first
    }
}
