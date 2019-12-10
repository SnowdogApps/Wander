//
//  String.swift
//  STPR
//
//  Created by Majid Jabrayilov on 9/24/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Foundation

extension String {
    func localized() -> String {
        let langCode = GlobalSettings.langCode
        return localized(withCode: langCode)
    }

    func localized(withCode code: String) -> String {
        guard
            let path = Bundle.main.path(forResource: code, ofType: "lproj"),
            let bundle = Bundle(path: path)
            else { return NSLocalizedString(self, comment: "") }

        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    func capitalize() -> String {
        let firstChar = String(prefix(1)).capitalized
        let restOfString = String(dropFirst())
        return firstChar + restOfString
    }
}