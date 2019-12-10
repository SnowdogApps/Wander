//
//  TabBar.swift
//  STPR
//
//  Created by Artur Chabera on 28/08/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class TabBar: UITabBar {
    enum Layout {
        static var itemWidth: CGFloat { return UIScreen.main.bounds.width / 5  }
        static var centralItemWidth: CGFloat = 56.0
        static let centralItemTopMargin: CGFloat = -8.0
    }
    
    private var buttonItems: [TabBarButton] = []
    
    convenience init(buttonItems: [TabBarButton]) {
        self.init()
        self.buttonItems = buttonItems
        setupUI()
    }
    
    private func setupUI() {
        barTintColor = .tabBarBackground
        isTranslucent = false

        guard !buttonItems.isEmpty else { return }
        for i in 0 ..< buttonItems.count {
            
            let button = buttonItems[i]
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
            
            if button.buttonStyle == .central {
                NSLayoutConstraint.activate([
                    button.heightAnchor.constraint(equalToConstant: Layout.centralItemWidth),
                    button.topAnchor.constraint(equalTo: topAnchor, constant: Layout.centralItemTopMargin),
                    button.centerXAnchor.constraint(equalTo: centerXAnchor),
                    button.widthAnchor.constraint(equalToConstant: Layout.centralItemWidth)
                    ])
                button.layer.cornerRadius = Layout.centralItemWidth / 2
            } else {
                NSLayoutConstraint.activate([
                    button.leftAnchor.constraint(equalTo: leftAnchor, constant: CGFloat(i) * Layout.itemWidth),
                    button.bottomAnchor.constraint(equalTo: bottomAnchor),
                    button.topAnchor.constraint(equalTo: topAnchor),
                    button.widthAnchor.constraint(equalToConstant: Layout.itemWidth)
                    ])
            }
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let centralButton = buttonItems.first(where: { $0.buttonStyle == .central }) {
            if centralButton.frame.contains(point) {
                return true
            }
        }

        return bounds.contains(point)
    }
}
