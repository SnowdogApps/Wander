//
//  Optional.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/9/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Foundation

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
