//
//  AuthAction.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/15/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import Foundation

enum AuthAction {
    case login
    case signUp

    var title: String {
        switch self {
        case .login: return "loginTitle".localized()
        case .signUp: return "signUpTitle".localized()
        }
    }

    var mainActionTitle: String {
        switch self {
        case .login: return "login".localized()
        case .signUp: return "signUp".localized()
        }
    }

    var secondActionTitle: String {
        switch self {
        case .login: return "signUp".localized()
        case .signUp: return "alreadyHaveAccount".localized()
        }
    }
}
