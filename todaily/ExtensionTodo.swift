//
//  ExtensionTodo.swift
//  todaily
//
//  Created by 이예민 on 2022/01/20.
//

import Foundation

extension Formatter {
    static let weekDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "dd일, EEEE"
        return formatter
    }()
}
