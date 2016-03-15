//
//  ResultsCalendarViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/9/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit
import CVCalendar

class ResultsCalendarViewController: UIViewController, CVCalendarViewDelegate, CVCalendarMenuViewDelegate {

    @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        calendarMenuView.commitMenuViewUpdate()
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func presentationMode() -> CalendarMode {
        return .MonthView
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UI Settings
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
