//
//  DateComponentsFormatter.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/15/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Foundation

extension DateComponentsFormatter {
    static var duration: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.second, .minute, .hour]
        return formatter
    }
}
