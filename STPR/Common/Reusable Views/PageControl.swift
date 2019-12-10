//
//  PageControl.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/24/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

final class PageControl: UIPageControl {
    private enum Layout {
        static let scale: CGFloat = 2
        static let circleScale: CGFloat = 1.5 / Layout.scale
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        transform = .init(scaleX: Layout.scale, y: Layout.scale)
        subviews.forEach {
            $0.transform = .init(scaleX: Layout.circleScale, y: Layout.circleScale)
        }
    }
}
