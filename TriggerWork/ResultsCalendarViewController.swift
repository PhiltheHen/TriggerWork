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
  
  // Firebase Manager
  let firManager = FIRDataManager()
  
  // Data for calendar
  var sessionDates = [[String : AnyObject]]()
  var selectedDay:DayView!

  // Session Data
  var sessions = [AnyObject]()
  var dataToPass = [NSArray]()

  // IBOutlets
  @IBOutlet weak var calendarMenuView: CVCalendarMenuView!
  @IBOutlet weak var calendarView: CVCalendarView!
  @IBOutlet weak var viewResultsButton: UIButton!
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var numberSessionsLabel: UILabel!
  @IBOutlet weak var sessionTimeLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = CVDate(date: NSDate()).globalDescription
    userNameLabel.text = firManager.currentUser.displayName
    
    viewResultsButton.disable()
    
    // Retrieve session dates and create listener for new session data
    firManager.retrieveDataForUser(firManager.userID) { (result) in
      
      self.sessions = Array(result.allValues)
      print("Found \(self.sessions.count) sessions for userID \(self.firManager.userID)")
    
      for session in self.sessions {
        let shotDate = session["date"] as! String
        let cvDate = CVDate(date: NSDate.stringToDate(shotDate))
        let shotData = session["shot_data"] as! NSArray
        let lastShot = shotData.lastObject as! NSDictionary
        if let elapsedTime = lastShot["time"] {
          self.sessionDates.append(["date" : cvDate.convertedDate()!,
            "sessionTime" : elapsedTime as! String])
        }
        self.calendarView.contentController.refreshPresentedMonth()
      }
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    calendarView.commitCalendarViewUpdate()
    calendarMenuView.commitMenuViewUpdate()
  }
  
  // MARK: IBActions
  @IBAction func viewResultsButtonPressed(sender: AnyObject) {
    dataToPass.removeAll()
    for session in sessions {
      let shotDate = session["date"] as! String
      let cvDate = CVDate(date: NSDate.stringToDate(shotDate))
      if cvDate.convertedDate() == selectedDay.date.convertedDate() {
        let shotData = session["shot_data"] as! NSArray
        dataToPass.append(shotData)
      }
    }
    
    if dataToPass.count > 0 {
      self.performSegueWithIdentifier("ViewResultsSegue", sender: self)
    }

  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ViewResultsSegue" {
      let controller = segue.destinationViewController as! ResultsDayViewController
      controller.sessionData = dataToPass
    }
  }
  
  // MARK: UI Settings
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

// MARK: - Required Calendar View Delegate Methods
extension ResultsCalendarViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
  func firstWeekday() -> Weekday {
    return .Sunday
  }
  
  func presentationMode() -> CalendarMode {
    return .MonthView
  }
  
  func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
    selectedDay = dayView

    if (dayView.date != nil) {
      
      // Write to labels
      guard let convertedDate = dayView.date.convertedDate() else { return }
      var totalTime: Double = 0
      var numberSessions: Int = 0
      for date in sessionDates {
        if date["date"] as! NSDate == convertedDate {
          if let sessionTime = date["sessionTime"] {
            // Necessary checks due to data arch changes in Dev database
            if let doubleTime = Double(sessionTime as! String) {
              totalTime = totalTime + doubleTime
            }
          }
          numberSessions = numberSessions + 1;
        }
      }
      if numberSessions > 0 {
        viewResultsButton.enable()
      } else {
        viewResultsButton.disable()
      }
      
      // Again, extra checks to maintain backward compatability with database
      let formattedSeconds = NSDate.formatElapsedSecondsDouble(totalTime.roundToHundredths())
      sessionTimeLabel.text = "Total time: \(formattedSeconds)"
      numberSessionsLabel.text = numberSessions == 1 ? "\(numberSessions) Session" : "\(numberSessions) Sessions"

    }
    
        print(dayView.date.commonDescription)
  }
  
  func presentedDateUpdated(date: Date) {
    if title != date.globalDescription {
      title = date.globalDescription
    }
  }
  
  func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
    let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
    circleView.fillColor = .clearColor()
    return circleView
  }
  
  func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
    if dayView.isCurrentDay {
      // Need to call this to update labels for current day
      didSelectDayView(dayView, animationDidFinish: false)
      return true
    }
    
    return false
  }
  
  func shouldScrollOnOutDayViewSelection() -> Bool {
    return false
  }
  
  func shouldAutoSelectDayOnWeekChange() -> Bool {
    return true
  }
  
  func shouldAutoSelectDayOnMonthChange() -> Bool {
    return true
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
  
  func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
    return [Colors.defaultGreenColor()]
  }
  
  func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
    // From CVCalendar View Demo Application
    let π = M_PI
    
    let ringSpacing: CGFloat = 3.0
    let ringInsetWidth: CGFloat = 1.0
    let ringVerticalOffset: CGFloat = 1.0
    var ringLayer: CAShapeLayer!
    let ringLineWidth: CGFloat = 4.0
    let ringLineColour: UIColor = Colors.defaultGreenColor()
    
    let newView = UIView(frame: dayView.bounds)
    
    let diameter: CGFloat = (newView.bounds.width) - ringSpacing
    let radius: CGFloat = diameter / 2.0
    
    let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
    
    ringLayer = CAShapeLayer()
    newView.layer.addSublayer(ringLayer)
    
    ringLayer.fillColor = nil
    ringLayer.lineWidth = ringLineWidth
    ringLayer.strokeColor = ringLineColour.CGColor
    
    let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
    let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
    let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
    let startAngle: CGFloat = CGFloat(-π/2.0)
    let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
    let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    
    ringLayer.path = ringPath.CGPath
    ringLayer.frame = newView.layer.bounds
    
    return newView
  }
  
  func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
    
    if (dayView.date != nil) {
      // Show user what days they shot
      guard let convertedDate = dayView.date.convertedDate() else { return false }
      
      for sessionDate in sessionDates {
        if sessionDate["date"] as! NSDate == convertedDate {
          return true
        }
      }
    }

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
