//
//  ResultsDayViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/16/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit
import CorePlot

class ResultsDayViewController: UIViewController {
  
  // Firebase Manager
  let firManager = FIRDataManager()

  // Data for plot
  var data = [String:String]()
  var sortedTimes = [(String, AnyObject)]()
  var sessionData = [NSArray]()
  var currentSession = NSArray()
  var dayString: String = ""
  var sessionCount: Int = 0
  
  // Core Plot
  let plot = CPTScatterPlot()
  var maxTime: Double = 0
  var maxValue: Double = 300.0

  // Layout Constraints
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var graphViewHeightConstraint: NSLayoutConstraint!
  
  // Storyboard elements
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var graphView: CPTGraphHostingView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var numberSessionsLabel: UILabel!
  
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = Colors.defaultBlackColor()
    tableView.separatorStyle = .None
    //loadTestData()
    
    userNameLabel.text = firManager.currentUser.displayName
    dateLabel.text = dayString;
    numberSessionsLabel.text = sessionCount == 1 ? "\(sessionCount) Session" : "\(sessionCount) Sessions"
    setupGraphView()
  }
  
  func loadTestData() {
    guard let path = NSBundle.mainBundle().pathForResource("sample_data", ofType: "json") else { return }
    do {
      let jsonData = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
      data = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as! [String : String]
      sortedTimes = Helpers.sortedKeysAndValuesFromDict(data)
    }
    catch let error as NSError {
      print("Failed to load: \(error.localizedDescription)")
    }
  }
  
  func animateViews() {
    view.layoutIfNeeded()
    
    UIView.animateWithDuration(1.0) {
      self.tableViewHeightConstraint.priority = UILayoutPriorityDefaultHigh;
      self.graphViewHeightConstraint.priority = UILayoutPriorityDefaultLow;
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: UI Settings
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }  
}

extension ResultsDayViewController: CPTPlotDataSource {
  func setupGraphView() {
    
    // Reset graph view
    graphView.hostedGraph = nil
    
    // Styles
    let dataLineStyle = CPTMutableLineStyle()
    dataLineStyle.lineWidth = 3.0
    dataLineStyle.lineColor = CPTColor(CGColor: Colors.defaultGreenColor().CGColor)
    
    // Plotting Space
    let graph = CPTXYGraph(frame: CGRectZero)
    
    let axisSet = graph.axisSet as! CPTXYAxisSet
    axisSet.xAxis?.labelingPolicy = .None
    axisSet.xAxis?.axisLineStyle = nil
    axisSet.xAxis?.hidden = true
    axisSet.yAxis?.labelingPolicy = .None
    axisSet.yAxis?.axisLineStyle = nil
    axisSet.yAxis?.hidden = true
    
    plot.dataSource = self
    plot.interpolation = .Curved
    plot.dataLineStyle = dataLineStyle
    
    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
    let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
    let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
    xRange.length = maxTime
    yRange.length = maxValue + 10.0
    plotSpace.xRange = CPTPlotRange(location: 0, length: maxTime)
    plotSpace.yRange = CPTPlotRange(location: Constants.MinYValue, length: maxValue + 10.0)
    
    graph.addPlot(plot)
    graphView.hostedGraph = graph
  }
  
  func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
    return UInt(currentSession.count)
  }
  
  func doubleForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> Double {
    var dataPoint = ""
    
    switch (fieldEnum) {
    case 0:
      guard let time = currentSession[Int(idx)]["time"] else { break }
      dataPoint = time as! String
      break;
    case 1:
      guard let value = currentSession[Int(idx)]["value"] else { break }
      dataPoint = value as! String
      break;
    default:
      break;
    }
    
    return Double(dataPoint)!
    
  }
}

extension ResultsDayViewController: CPTScatterPlotDataSource {
  func symbolForScatterPlot(plot: CPTScatterPlot, recordIndex idx: UInt) -> CPTPlotSymbol? {
    return nil
  }
}

extension ResultsDayViewController: UITableViewDelegate {
  
}

extension ResultsDayViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! SessionTableViewCell
    
    return cell
  }
  
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    // Need control over when delegate and data source are set for the collection view
    guard let tableViewCell = cell as? SessionTableViewCell else { return }
    tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return 1
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sessionData.count
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    var time = ""
    let currentSessionData = sessionData[section]
    let lastShot = currentSessionData.lastObject as! NSDictionary
    if let elapsedTime = lastShot["time"] {
      if let doubleTime = Double(elapsedTime as! String) {
        time = NSDate.formatElapsedSecondsDouble(doubleTime.roundToHundredths())
      }
    }
    return "Session \(section+1): \(time)"
  }
}

extension ResultsDayViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ShotCollectionViewCell
    
    var time = ""
    let currentSessionData = sessionData[collectionView.tag]
    let lastShot = currentSessionData.lastObject as! NSDictionary
    if let elapsedTime = lastShot["time"] {
      if let doubleTime = Double(elapsedTime as! String) {
        time = NSDate.formatElapsedSecondsDouble(doubleTime.roundToHundredths())
      }
    }
    
    cell.timeLabel.text = time
    
    return cell
  }
  
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    // Generate graph for selected session
    currentSession = sessionData[collectionView.tag]
    
    let lastShot = currentSession.lastObject as! NSDictionary
    if let elapsedTime = lastShot["time"] {
      if let doubleTime = Double(elapsedTime as! String) {
        maxTime = doubleTime
      }
    }
    
    self.setupGraphView()
    
    if (tableViewHeightConstraint.priority == UILayoutPriorityDefaultLow) {
      animateViews()
    }
  }
}

extension ResultsDayViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return 1
  }
  
}


