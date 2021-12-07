//
//  GraphViewController.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/11/28.
//

import UIKit
import Charts
import RealmSwift
import SwiftUI

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
    
    var toolBar:UIToolbar{
        let toolBarRect = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 35)
        let toolBar = UIToolbar(frame: toolBarRect)
        let toolBarItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        toolBar.setItems([toolBarItem], animated: true)
        return toolBar
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
        if let startDateText = startDateTextField.text,
           let endDateText = endDateTextField.text,
           let startDate = dateFormatter.date(from: startDateText),
           let endDate = dateFormatter.date(from: endDateText){
            var filterRecord = Array(realm.objects(WeightRecord.self).filter("date BETWEEN {%@, %@}",startDate,endDate))
            filterRecord.sort(by: {$0.date < $1.date})
            recordList = filterRecord
        }
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
        startDateTextField.inputAccessoryView = toolBar
        endDateTextField.inputAccessoryView = toolBar
        startDatePicker.addTarget(self, action: #selector(didChangeStartDate), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(didChangeEndDate), for: .valueChanged)
    }
    
    @objc func didTapDone(){
        setRecord()
        updateGraph()
        view.endEditing(true)
    }
    
    @objc func didChangeStartDate(picker:UIDatePicker){
        startDateTextField.text = dateFormatter.string(from: picker.date)
    }
    
    @objc func didChangeEndDate(picker:UIDatePicker){
        endDateTextField.text = dateFormatter.string(from: picker.date)
    }
}
