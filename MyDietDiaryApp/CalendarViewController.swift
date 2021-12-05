//
//  CalenderViewController.swift
//  MyDietDiaryApp
//
//  Created by 米谷裕輝 on 2021/11/28.
//

import UIKit
import FSCalendar
import RealmSwift

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
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecord()
        calendarView.reloadData()
        print("viewWillAppear")
    }
    
    var recordList:[WeightRecord] = []
    
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
    //新規登録時と登録した日付タップ時呼ぶメソッド。新規登録時はデータがないためオプショナル型でデフォルトnilにしている
    func transitionToEditorView(with record:WeightRecord? = nil){
        let storyboard = UIStoryboard(name: "EditorViewController", bundle: nil)
        guard let editorViewController = storyboard.instantiateInitialViewController() as? EditorViewController else{return}
        if let record = record {
            editorViewController.record = record
        }
        editorViewController.deligate = self
        present(editorViewController, animated: true)
    }
    
    func getRecord(){
        let realm = try! Realm()
        recordList = Array(realm.objects(WeightRecord.self))
    }
}

extension CalendarViewController:FSCalendarDataSource{
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateList = recordList.map({$0.date.zeroclock})
        let isEqualDate = dateList.contains(date.zeroclock)
        return isEqualDate ? 1:0
    }
}

extension CalendarViewController:FSCalendarDelegate{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.deselect(date)
        guard let record = recordList.first(where: {$0.date.zeroclock == date.zeroclock}) else {return}
        transitionToEditorView(with: record)
    }
}

extension CalendarViewController:EditorViewControllerDeligate{
    func recordUpdate() {
        getRecord()
        calendarView.reloadData()
    }
}
