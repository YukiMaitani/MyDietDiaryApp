//
//  CalenderViewController.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/11/28.
//

import UIKit
import FSCalendar

class CalendarViewController:UIViewController{
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addButton(_ sender: Any) {
        transitionToEditorView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendar()
        configureButton()
    }
    
    func configureCalendar(){
        calendarView.appearance.headerDateFormat = "yyyy年MM月dd日"
        calendarView.appearance.todayColor = .orange
        calendarView.appearance.headerTitleColor = .orange
        calendarView.appearance.weekdayTextColor = .black
        calendarView.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendarView.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendarView.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendarView.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendarView.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendarView.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendarView.calendarWeekdayView.weekdayLabels[6].text = "土"
        calendarView.calendarWeekdayView.weekdayLabels[0].textColor = .red
        calendarView.calendarWeekdayView.weekdayLabels[6].textColor = .blue
    }
    
    func configureButton(){
        addButton.layer.cornerRadius = addButton.bounds.width/2
    }
    
    func transitionToEditorView(){
        let storyboard = UIStoryboard(name: "EditorViewController", bundle: nil)
        guard let editorViewController = storyboard.instantiateInitialViewController() as? EditorViewController else{return}
        present(editorViewController, animated: true)
    }
}
