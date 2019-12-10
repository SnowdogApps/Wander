//
//  ExperienceBar.swift
//  STPR
//
//  Created by Artur Chabera on 03/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import UIKit

class ExperienceBar: UIView {
    
    var experience: (current: Int, max: Int) = (0, 100) {
        didSet { updateBar() }
    }

    private var barBackground: UIColor = .tetrialyFont
    private var overlayColor: UIColor = .yellow
    private var widthConstraint: NSLayoutConstraint!
    private var overlayView = UIView()

    private var gradientLayerName: String { "gradientLayer" }

    lazy var firstGradientLayer: CAGradientLayer = {
        makeGradient(CGRect( x: 0, y: 0, width: bounds.width * 2, height: bounds.height))
    }()

    lazy var secondGradientLayer: CAGradientLayer = {
        makeGradient(CGRect(x: -bounds.width * 2, y: 0, width: bounds.width * 2, height: bounds.height))
    }()

    lazy var gradientAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 6
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.repeatCount = .infinity
        animation.autoreverses = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        return animation
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }

    private func setupUI() {
        backgroundColor = barBackground
        overlayView.backgroundColor = overlayColor
        
        widthConstraint = overlayView.widthAnchor.constraint(equalToConstant: 0)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)

        NSLayoutConstraint.activate([
                overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
                overlayView.topAnchor.constraint(equalTo: topAnchor),
                overlayView.leftAnchor.constraint(equalTo: leftAnchor),
                widthConstraint
            ])
    }
    
    private func updateBar() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let expBarWidth = (self.frame.width * CGFloat(self.experience.current)) / CGFloat(self.experience.max)
            self.widthConstraint.constant = min(expBarWidth, self.frame.width)
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { self.layoutSubviews() }
            animator.startAnimation()
        }
    }

    private func applyGradient() {
        guard !(overlayView.layer.sublayers?.contains(where: { $0.name == gradientLayerName }) ?? false) else { return }
        overlayView.clipsToBounds = true
        overlayView.layer.insertSublayer(firstGradientLayer, at: 0)
        overlayView.layer.insertSublayer(secondGradientLayer, at: 0)
    }

    func animateGradient() {
        firstGradientLayer.add(gradientAnimation, forKey: "gradientLayerAnimation")
        secondGradientLayer.add(gradientAnimation, forKey: "gradientLayerAnimation")
    }

    private func makeGradient(_ frame: CGRect) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = gradientLayerName

        var gradientColors = [
            UIColor.gradient0.cgColor, UIColor.gradient1.cgColor,
            UIColor.gradient2.cgColor, UIColor.gradient3.cgColor,
            UIColor.gradient4.cgColor]
        let reversedColors: [CGColor] = gradientColors.reversed()
        gradientColors.append(contentsOf: reversedColors)
        gradientLayer.colors = gradientColors

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = frame

        return gradientLayer
    }
}
