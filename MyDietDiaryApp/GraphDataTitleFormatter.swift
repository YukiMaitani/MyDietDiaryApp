//
//  GraphDataTitleFormatter.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/12/07.
//

import Foundation
import Charts

class GraphDataTitleFormatter:IAxisValueFormatter{
    var dateList:[Date] = []
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        print(value)
        print(dateList)
        let index = Int(value)
        guard dateList.count > index else {return ""}
        let targetDate = dateList[index]
        //戻り値がString型なのでdateformatterでDate型からString型に直している
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: targetDate)
    }
}
