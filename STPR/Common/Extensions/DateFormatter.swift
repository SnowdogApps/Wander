//
//  DateFormatter.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/14/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }
}
