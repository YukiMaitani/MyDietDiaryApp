//
//  Date+Extension .swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/12/05.
//

import Foundation

extension Date{
    var calendar:Calendar{
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        calendar.locale = Locale(identifier: "jp-JP")
        return calendar
    }
    
    func fiexd(year:Int? = nil, month:Int? = nil, day:Int? = nil, hour:Int? = nil, minute:Int? = nil, second:Int? = nil) ->Date{
        var comp = DateComponents()
        comp.year = year ?? calendar.component(.year, from: self)
        comp.month = month ?? calendar.component(.month, from: self)
        comp.day = day ?? calendar.component(.day, from: self)
        comp.hour = hour ?? calendar.component(.hour, from: self)
        comp.minute = minute ?? calendar.component(.minute, from: self)
        comp.second = second ?? calendar.component(.second, from: self)
        return calendar.date(from: comp)!
    }
    
    var zeroclock:Date{
        return fiexd(hour: 0, minute: 0, second: 0)
    }
}
