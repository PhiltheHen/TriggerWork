//
//  ResultsCalendarViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/9/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit
import CVCalendar

class ResultsCalendarViewController: UIViewController {

    @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = CVDate(date: NSDate()).globalDescription
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        calendarView.commitCalendarViewUpdate()
        calendarMenuView.commitMenuViewUpdate()
    }
    
    // MARK: UI Settings
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

// MARK: - Required Calendar View Delegate MEthods
extension ResultsCalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        print(dayView.date.commonDescription)
    }
    
    func presentedDateUpdated(date: Date) {
        if title != date.globalDescription {
            title = date.globalDescription
        }
    }
    
    func shouldScrollOnOutDayViewSelection() -> Bool {
        return false
    }
    
    func shouldAutoSelectDayOnWeekChange() -> Bool {
        return false
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func topMarker(shouldDisplayOnDayView dayView: DayView) -> Bool {
        return false
    }
    
    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        return false
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: DayView) -> Bool {
        return false
    }
}

// MARK: - Optional Calendar View Appearance Methods
extension ResultsCalendarViewController: CVCalendarViewAppearanceDelegate {
    func dayOfWeekFont() -> UIFont {
        return Fonts.defaultLightFontWithSize(15.0)
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func dayLabelWeekdayFont() -> UIFont {
        return Fonts.defaultLightFontWithSize(15.0)
    }
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func dayLabelPresentWeekdayHighlightedBackgroundAlpha() -> CGFloat {
        return 0.0
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundAlpha() -> CGFloat {
        return 0.0
    }
    
    func dayLabelWeekdayHighlightedBackgroundAlpha() -> CGFloat {
        return 0.0
    }
    
    func dayLabelWeekdaySelectedBackgroundAlpha() -> CGFloat {
        return 0.0
    }
}
