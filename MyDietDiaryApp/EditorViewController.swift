//
//  EditViewController.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/12/01.
//

import UIKit
import RealmSwift

protocol EditorViewControllerDeligate{
    func recordUpdate()
}

class EditorViewController:UIViewController{
    
    @IBAction func saveButoon(_ sender: Any) {
        saveRecord()
    }
    @IBAction func deleteButton(_ sender: Any) {
        deleteRecord()
    }
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var inputDateTextField: UITextField!
    @IBOutlet weak var inputWeightTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWightTextField()
        configureDateTextField()
        configureSaveButton()
        print(record)
    }
    @objc func didTapDone(){
        view.endEditing(true)
    }
    var record = WeightRecord()
    var deligate:EditorViewControllerDeligate?
    
    var toolBar:UIToolbar{
        let toolBarRect = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 35)
        let toolBar = UIToolbar(frame: toolBarRect)
        let toolBarItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        toolBar.setItems([toolBarItem], animated: true)
        return toolBar
    }
    
    var dateFormatter:DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "jp-JP")
        dateFormatter.dateStyle = .long
        dateFormatter.timeZone = .current
        return dateFormatter
    }
    
    func configureWightTextField(){
        inputWeightTextField.inputAccessoryView = toolBar
        inputWeightTextField.text = String(record.weight)
    }
    var datepicker:UIDatePicker{
        let datepicker = UIDatePicker()
        datepicker.preferredDatePickerStyle = .wheels
        datepicker.datePickerMode = .date
        datepicker.timeZone = .current
        datepicker.locale = Locale(identifier: "jp-JP")
        datepicker.date = record.date
        datepicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        return datepicker
    }
    
    func configureDateTextField(){
        inputDateTextField.inputView = datepicker
        inputDateTextField.inputAccessoryView = toolBar
        inputDateTextField.text = dateFormatter.string(from: record.date)
    }
    //＠いつ呼び出されるか
    @objc func didChangeDate(picker:UIDatePicker){
        inputDateTextField.text = dateFormatter.string(from: picker.date)
    }
    
    func configureSaveButton(){
        saveButton.layer.cornerRadius = 5
    }
    
    func saveRecord(){
        let realm = try! Realm()
        try! realm.write{
            if let dateText = inputDateTextField.text,
               let date = dateFormatter.date(from: dateText){
                record.date = date
            }
            
            if let weightText = inputWeightTextField.text,
               let weight = Double(weightText){
                record.weight = weight
            }
            realm.add(record)
        }
        deligate?.recordUpdate()
        dismiss(animated: true)
        
    }
    
    func deleteRecord(){
        let calendar = Calendar(identifier: .gregorian)
        let startOfDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: record.date)
        let endOfDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: record.date)
        let realm = try! Realm()
        let recordList = Array(realm.objects(WeightRecord.self).filter("date BETWEEN {%@,%@}",startOfDate,endOfDate))
        recordList.forEach({record in
            try! realm.write {
                realm.delete(record)
            }
        })
        deligate?.recordUpdate()
        dismiss(animated: true)
    }
}


