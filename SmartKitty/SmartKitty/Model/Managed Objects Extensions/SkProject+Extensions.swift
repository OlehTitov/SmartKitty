//
//  SkProject+Extensions.swift
//  SmartKitty
//
//  Created by Oleh Titov on 05.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import CoreData

extension SkProject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //MARK: - DEADLINE AS DATE
        var deadlineAsDate: Date? {
            return convertStringToDate(str: deadline)
        }
        
        //MARK: - IS TODAY
        var isToday: Bool? {
            return compareDateIfToday(date: deadlineAsDate!)
        }
        
        //MARK: - IS TOMOROOW
        var isTomorrow: Bool? {
            return compareDateIfTomorrow(date: deadlineAsDate!)
        }
        
    }
    
    private func convertStringToDate(str: String?) -> Date {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = RFC3339DateFormatter.date(from: str!)!
        return date
    }
    
    private func compareDateIfToday(date: Date) -> Bool {
        let calendar = NSCalendar.current
        let result = calendar.isDateInToday(date)
        return result
    }
    
    private func compareDateIfTomorrow(date: Date) -> Bool {
        let calendar = NSCalendar.current
        let result = calendar.isDateInTomorrow(date)
        return result
    }
}