//
//  NumberFormatter.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/25/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Foundation

extension NumberFormatter {
    static var percent: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }
}
