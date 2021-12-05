//
//  EditViewController.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/12/01.
//

import UIKit
import RealmSwift

class EditorViewController:UIViewController{
    
    @IBAction func saveButoon(_ sender: Any) {
        saveRecord()
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
    }
    var datepicker:UIDatePicker{
        let datepicker = UIDatePicker()
        datepicker.preferredDatePickerStyle = .wheels
        datepicker.datePickerMode = .date
        datepicker.timeZone = .current
        datepicker.locale = Locale(identifier: "jp-JP")
        datepicker.date = Date()
        datepicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        return datepicker
    }
    
    func configureDateTextField(){
        inputDateTextField.inputView = datepicker
        inputDateTextField.inputAccessoryView = toolBar
        inputDateTextField.text = dateFormatter.string(from: Date())
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
        dismiss(animated: true)
    }
}


