//
//  OnboardingViewController.swift
//  STPR
//
//  Created by Majid Jabrayilov on 8/30/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit
import Combine

protocol OnboardingDelegate: AnyObject {
    func onboardingDidFinished()
}

final class OnboardingViewController: UIViewController {
    @IBOutlet private weak var pageControl: PageControl!
    @IBOutlet private weak var continueButton: FilledButton!
    @IBOutlet private weak var pagerContainer: UIView!

    weak var delegate: OnboardingDelegate?

    private let pagesVC = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )

    private var pageViewControllers: [UIViewController] = []
    private let modelController: OnboardingModelController
    private var cancellable: AnyCancellable?

    init(modelController: OnboardingModelController) {
        self.modelController = modelController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func moveToNext() {
        let nextIndex = pageControl.currentPage + 1
        if nextIndex < pageControl.numberOfPages {
            pageControl.currentPage = nextIndex
            continueButton.setTitle(modelController.pages[nextIndex].action, for: .normal)
            pagesVC.setViewControllers(
                [pageViewControllers[nextIndex]],
                direction: .forward,
                animated: true
            )
        } else {
            if modelController.permissionsNeeded {
                cancellable = modelController
                    .requestPermissionsPublisher()
                    .sink(receiveCompletion: { [weak self] _ in
                        // workaround for a weird Combine bug
                        DispatchQueue.main.async {
                            self?.modelController.finishBoarding()
                            self?.delegate?.onboardingDidFinished()
                        }
                    }, receiveValue: { _ in })
            } else {
                modelController.finishBoarding()
                delegate?.onboardingDidFinished()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        continueButton.setTitle(modelController.pages[0].action, for: .normal)
        pageViewControllers = modelController.pages.enumerated().map { index, page in
            let pageVC = OnboardingPageViewController()
            pageVC.page = page
            pageVC.restorationIdentifier = String(index)
            return pageVC
        }

        pageControl.numberOfPages = pageViewControllers.count
        pagesVC.dataSource = self
        pagesVC.delegate = self

        pageViewControllers.first.map {
            pagesVC.setViewControllers(
                [$0],
                direction: .forward,
                animated: true
            )
        }
        addChild(pagesVC, to: pagerContainer)
    }

    @IBAction func pageControlChanged() {
        guard
            let identifier = pagesVC.viewControllers?.first?.restorationIdentifier,
            let oldIndex = Int(identifier)
            else { return }

        let newIndex = pageControl.currentPage
        continueButton.setTitle(modelController.pages[newIndex].action, for: .normal)
        pagesVC.setViewControllers(
            [pageViewControllers[newIndex]],
            direction: newIndex > oldIndex ? .forward : .reverse,
            animated: true
        )
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let id = viewController.restorationIdentifier,
            let index = Int(id),
            index - 1 >= 0
            else { return nil }

        return pageViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let id = viewController.restorationIdentifier,
            let index = Int(id),
            index + 1 < modelController.pages.count
            else { return nil }

        return pageViewControllers[index + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard
            let id = pendingViewControllers.first?.restorationIdentifier,
            let index = Int(id)
            else { return }
        pageControl.currentPage = index
        continueButton.setTitle(modelController.pages[index].action, for: .normal)
    }
}
