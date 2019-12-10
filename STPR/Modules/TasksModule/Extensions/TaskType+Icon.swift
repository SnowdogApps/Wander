//
//  TaskType+Icon.swift
//  STPR
//
//  Created by Majid Jabrayilov on 10/1/19.
//  Copyright © 2019 Snowdog. All rights reserved.
//
import UIKit

extension TaskType {
    var icon: UIFont.Icon {
        switch self {
        case .collectItems: return UIFont.Icon.collect
        case .goToLocation: return UIFont.Icon.walk
        case .leaveLocation: return UIFont.Icon.run
        case .question: return UIFont.Icon.question
        case .scanMarker: return UIFont.Icon.scan
        case .selectPath: return UIFont.Icon.map
        case .showItemToCamera: return UIFont.Icon.show
        }
    }
}
