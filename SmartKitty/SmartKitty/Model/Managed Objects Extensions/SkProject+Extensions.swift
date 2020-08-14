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
    
    //MARK: - UPDATE COMPUTED VALUES WITH EACH FETCH
    public override func awakeFromFetch() {
        super.awakeFromFetch()
        if deadlineAsDate != nil {
            isToday = compareDateIfToday(date: deadlineAsDate!)
            isTomorrow = compareDateIfTomorrow(date: deadlineAsDate!)
        }
        
    }
    
    //MARK: - CALCULATE THE VALUES WHEN SK PROJECT IS CREATED
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        if deadlineAsDate != nil {
            isToday = compareDateIfToday(date: deadlineAsDate!)
            isTomorrow = compareDateIfTomorrow(date: deadlineAsDate!)
        }
        
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
