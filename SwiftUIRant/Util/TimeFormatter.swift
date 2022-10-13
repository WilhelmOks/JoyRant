//
//  TimeFormatter.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 27.09.22.
//

import Foundation

struct TimeFormatter {
    static let shared = Self()
    
    let dateFormatter = DateFormatter()
    let relativeDateTimeFormatter = RelativeDateTimeFormatter()
    
    private init() {
        let currentLocale = Locale.current
        
        // a locale with the current region of the user's device but always in english:
        let locale = Locale(
            languageCode: .init("en"),
            script: currentLocale.scriptCode.flatMap { Locale.Script.init($0) },
            languageRegion: currentLocale.region
        )
        
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = locale
        
        relativeDateTimeFormatter.dateTimeStyle = .numeric
        relativeDateTimeFormatter.formattingContext = .standalone
        relativeDateTimeFormatter.unitsStyle = .abbreviated
        relativeDateTimeFormatter.locale = locale
    }
    
    func string(fromDate date: Date) -> String {
        let relativeThreshold: TimeInterval = 60 * 60 * 24 * 6 // 6 days
        let now = Date()
        if date.addingTimeInterval(relativeThreshold) > now {
            return relativeDateTimeFormatter.string(for: date) ?? ""
        } else {
            return dateFormatter.string(from: date)
        }
    }
    
    func string(fromSeconds seconds: Int) -> String {
        string(fromDate: .init(timeIntervalSince1970: TimeInterval(seconds)))
    }
}
