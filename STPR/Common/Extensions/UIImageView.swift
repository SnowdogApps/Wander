//
//  UIImageView.swift
//  STPR
//
//  Created by Artur Chabera on 16/09/2019.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Kingfisher

extension UIImageView {
    func setImage(from url: URL, options: KingfisherOptionsInfo? = nil) {
        kf.setImage(with: url, options: options)
    }
}

struct BlackWhiteColorFilter: CIImageProcessor {
    let filter = Filter { input in
        guard let filter = CIFilter(name: "CIColorControls") else {
            return nil
        }

        filter.setValue(input, forKey: "inputImage")
        filter.setValue(0.2, forKey: "inputSaturation")
        filter.setValue(1.0, forKey: "inputContrast")
        filter.setValue(0.1, forKey: "inputBrightness")

        return filter.outputImage
    }

    var identifier: String = "blackWhiteColorFilter"
}
