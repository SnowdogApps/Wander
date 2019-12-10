//
//  ProgressView.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/25/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

final class ProgressView: UIView {
    private let valueLabel = UILabel()

    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()

    var progress: Double = 0.0 {
        didSet {
            valueLabel.text = NumberFormatter.percent.string(from: progress as NSNumber)
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .appBackground
        valueLabel.layer.addSublayer(backgroundLayer)
        valueLabel.layer.addSublayer(progressLayer)

        layer.cornerRadius = 8
        layer.shadowOpacity = 1
        layer.shadowOffset = .init(width: 1, height: 1)
        layer.shadowColor = UIColor.appBackground.cgColor
        layer.masksToBounds = false

        valueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textAlignment = .center
        valueLabel.textColor = .mainFont
        valueLabel.numberOfLines = 0

        addSubview(valueLabel)
        valueLabel.fit(to: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = bounds.inset(by: .init(top: 16, left: 16, bottom: 16, right: 16))

        backgroundLayer.path = UIBezierPath(ovalIn: frame).cgPath
        backgroundLayer.strokeColor = UIColor.tetrialyFont.cgColor
        backgroundLayer.lineWidth = 4.0
        backgroundLayer.fillColor = UIColor.clear.cgColor

        let center = CGPoint(x: frame.midX, y: frame.midY)
        progressLayer.path = UIBezierPath(
            arcCenter: center,
            radius: frame.width / 2,
            startAngle: 1.5 * CGFloat.pi,
            endAngle: 2 * CGFloat.pi * CGFloat(progress) + 1.5 * CGFloat.pi,
            clockwise: true
        ).cgPath

        progressLayer.strokeColor = UIColor.appYellow.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 4.0
    }
}
