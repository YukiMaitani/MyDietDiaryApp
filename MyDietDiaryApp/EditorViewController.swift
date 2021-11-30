//
//  EditViewController.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/12/01.
//

import UIKit

class EditorViewController:UIViewController{
    
    @IBOutlet weak var inputWeightTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWightTextField()
    }
    @objc func didTapDone(){
        view.endEditing(true)
    }
    func configureWightTextField(){
        let toolBarRect = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: 35)
        let toolBar = UIToolbar(frame: toolBarRect)
        let toolBarItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        toolBar.setItems([toolBarItem], animated: true)
        inputWeightTextField.inputAccessoryView = toolBar
    }
}


