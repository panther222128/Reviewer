//
//  Date+FormattedString.swift
//  Reviewer
//
//  Created by Horus on 4/10/24.
//

import Foundation

extension Date {
    func formatYearMonthDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: self)
    }
    
    func formatYearMonthDateWithoutPoint() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: self)
    }
}
