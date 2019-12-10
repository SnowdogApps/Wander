//
//  UIStoryboard.swift
//  STPR
//
//  Created by Marcel Mierzejewski on 18/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

protocol StoryboardIdentifiable {
    static var identifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController: StoryboardIdentifiable { }

extension UIStoryboard {
    enum Storyboard: String {
        case notificationAlert

        var filename: String {
            return rawValue.capitalize()
        }
    }

    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }

    static func storyboard(storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.filename, bundle: bundle)
    }

    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.identifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.identifier) ")
        }

        return viewController
    }
}
