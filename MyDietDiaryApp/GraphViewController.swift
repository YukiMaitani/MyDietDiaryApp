//
//  GraphViewController.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/11/28.
//

import UIKit
import Charts
import RealmSwift

class GraphViewController:UIViewController{
    @IBOutlet weak var graphView: LineChartView!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    var recordList = [WeightRecord]()
    
    var datepicker:UIDatePicker{
        let datepicker = UIDatePicker()
        datepicker.preferredDatePickerStyle = .wheels
        datepicker.datePickerMode = .date
        datepicker.timeZone = .current
        datepicker.locale = Locale(identifier: "jp-JP")
        return datepicker
    }
    
    var dateFormatter:DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "jp-JP")
        dateFormatter.dateStyle = .long
        dateFormatter.timeZone = .current
        return dateFormatter
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setRecord()
        updateGraph()
        configureGraph()
        configureTextField()
    }
    
    func setRecord(){
        let realm = try! Realm()
        var result = Array(realm.objects(WeightRecord.self))
        result.sort(by: {$0.date < $1.date})
        recordList = result
    }
    
    func updateGraph(){
        var entry = [ChartDataEntry]()
        recordList.enumerated().forEach({index,record in
            let data = ChartDataEntry(x: Double(index), y: record.weight)
            entry.append(data)
        })
        let dataSet = LineChartDataSet(entries: entry, label: "体重")
        graphView.data = LineChartData(dataSet: dataSet)
        graphView.data?.notifyDataChanged()
        graphView.notifyDataSetChanged()
    }
    
    func configureGraph(){
        graphView.xAxis.labelPosition = .bottom
        let titleFormatter = GraphDataTitleFormatter()
        let dateList = recordList.map({$0.date})
        titleFormatter.dateList = dateList
        graphView.xAxis.valueFormatter = titleFormatter
    }
    
    func configureTextField(){
        let startDatePicker = datepicker
        let endDatePicker = datepicker
        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker
        let today = Date()
        let pastMonth = Calendar.current.date(byAdding: .month, value: -1, to: today)!
        startDatePicker.date = pastMonth
        endDatePicker.date = today
        startDateTextField.text = dateFormatter.string(from: pastMonth)
        endDateTextField.text = dateFormatter.string(from: today)
    }
}
