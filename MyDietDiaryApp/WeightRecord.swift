//
//  WeightRecord.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/12/01.
//

import Foundation
import RealmSwift

class WeightRecord:Object{
    override static func primaryKey() -> String? {
        return "id"
    }
    @objc dynamic var id:String = UUID().uuidString
    @objc dynamic var weight:Double = 0
    @objc dynamic var date:Date = Date()
}
