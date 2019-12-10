//
//  UIColor.swift
//  STPR
//
//  Created by Artur Chabera on 17/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

/**
 Colors from app designs: https://app.zeplin.io/project/5cee489f156b3d1dd4de2677/dashboard
 Color converting from hex to UIColor: https://www.uicolor.xyz/#/hex-to-ui
 */

fileprivate enum AppColor {
    /// Cells background e.g. MissionCell container background + Navigation bar
    /// Dark theme: dark
    static let darkBackground = UIColor(red: 0.13, green: 0.13, blue: 0.22, alpha: 1.0)

    /// ViewControllers background
    /// Dark theme: almost_black
    static let appDarkBackground = UIColor(red: 0.04, green: 0.06, blue: 0.09, alpha: 1.0)

    /// Tab bar background
    static let tabBarBackground = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

    /// Main font color
    /// Dark theme: pale_gray
    static let mainFontDark = UIColor(red: 0.98, green: 0.98, blue: 1.00, alpha: 1.0)

    /// Secondary font color
    /// Dark theme: light_periwinkle
    static let secondaryFontDark = UIColor(red: 0.80, green: 0.84, blue: 0.93, alpha: 1.0)

    /// Tetrialy font color
    /// Dark theme: steel
    static let tetrialyFontDark = UIColor(red: 0.49, green: 0.51, blue: 0.58, alpha: 1.0)

    static let greenBlue = UIColor(red: 0, green: 0.8, blue: 0.47, alpha: 1)
    static let butterScotch = UIColor(red: 1, green: 0.76, blue: 0.23, alpha: 1)
    static let cherry = UIColor(red: 0.81, green: 0.00, blue: 0.22, alpha: 1.0)
}

extension UIColor {
    static var containerBackground: UIColor {
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return AppColor.darkBackground
            } else {
                return AppColor.darkBackground
            }
        }
    }

    static var appBackground: UIColor {
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return AppColor.appDarkBackground
            } else {
                return AppColor.appDarkBackground
            }
        }
    }

    static var tabBarBackground: UIColor {
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return AppColor.tabBarBackground
            } else {
                return AppColor.tabBarBackground
            }
        }
    }

    static var mainFont: UIColor {
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return AppColor.mainFontDark
            } else {
                return AppColor.mainFontDark
            }
        }
    }

    static var secondaryFont: UIColor {
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return AppColor.secondaryFontDark
            } else {
                return AppColor.secondaryFontDark
            }
        }
    }

    static var tetrialyFont: UIColor {
        return UIColor { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return AppColor.tetrialyFontDark
            } else {
                return AppColor.tetrialyFontDark
            }
        }
    }

    static let gradient0 = UIColor(red: 1.00, green: 0.79, blue: 0.31, alpha: 1.0)
    static let gradient1 = UIColor(red: 1.00, green: 0.58, blue: 0.34, alpha: 1.0)
    static let gradient2 = UIColor(red: 1.00, green: 0.34, blue: 0.49, alpha: 1.0)
    static let gradient3 = UIColor(red: 1.00, green: 0.12, blue: 0.70, alpha: 1.0)
    static let gradient4 = UIColor(red: 0.77, green: 0.22, blue: 0.91, alpha: 1.0)

    static var appGreen: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? AppColor.greenBlue : AppColor.greenBlue
        }
    }

    static var appYellow: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? AppColor.butterScotch : AppColor.butterScotch
        }
    }

    static var appRed: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? AppColor.cherry : AppColor.cherry
        }
    }
}
