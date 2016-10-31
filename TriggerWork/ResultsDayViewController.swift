//
//  ResultsDayViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 3/16/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit
import CorePlot
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
  var maxValue: Double = 0

  // Layout Constraints
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var graphViewHeightConstraint: NSLayoutConstraint!
  
  // Storyboard elements
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var graphView: CPTGraphHostingView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var numberSessionsLabel: UILabel!
  @IBOutlet weak var closeGraphButton: UIButton!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = Colors.defaultBlackColor()
    tableView.separatorStyle = .none
    //loadTestData()
    
    userNameLabel.text = firManager.currentUser.displayName
    dateLabel.text = dayString;
    numberSessionsLabel.text = sessionCount == 1 ? "\(sessionCount) Session" : "\(sessionCount) Sessions"
    setupGraphView()
    closeGraphButton.isHidden = true
    
   // let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
  //  self.graphView.addGestureRecognizer(pinchGestureRecognizer)
  }
  
  func loadTestData() {
    guard let path = Bundle.main.path(forResource: "sample_data", ofType: "json") else { return }
    do {
      let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
      data = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String : String]
      sortedTimes = Helpers.sortedKeysAndValuesFromDict(data as Dictionary<String, AnyObject>)
    }
    catch let error as NSError {
      print("Failed to load: \(error.localizedDescription)")
    }
  }
  
  func animateViews(_ showGraph:Bool) {
    view.layoutIfNeeded()
    
    closeGraphButton.isHidden = !showGraph

    self.tableViewHeightConstraint.priority = showGraph ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
    self.graphViewHeightConstraint.priority = showGraph ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh

    UIView.animate(withDuration: 1.0, animations: {
      self.view.layoutIfNeeded()
    }) 
  }
  
  @IBAction func closeGraphView(_ sender: AnyObject) {
    animateViews(false)
  }
  
  // MARK: UI Settings
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
  
  func handlePinch(gestureRecognizer: UIGestureRecognizer) {
  //  if gestureRecognizer.state == .
  }
}

extension ResultsDayViewController: CPTPlotDataSource, CPTPlotSpaceDelegate {
  func setupGraphView() {
    
    // Reset graph view
    graphView.hostedGraph = nil
    
    // Styles
    let dataLineStyle = CPTMutableLineStyle()
    dataLineStyle.lineWidth = 3.0
    dataLineStyle.lineColor = CPTColor(cgColor: Colors.defaultGreenColor().cgColor)
    
    // Plotting Space
    let graph = CPTXYGraph(frame: CGRect.zero)
    
    let axisSet = graph.axisSet as! CPTXYAxisSet
    axisSet.xAxis?.labelingPolicy = .none
    axisSet.xAxis?.axisLineStyle = nil
    axisSet.xAxis?.isHidden = true
    axisSet.yAxis?.labelingPolicy = .none
    axisSet.yAxis?.axisLineStyle = nil
    axisSet.yAxis?.isHidden = true
    
    plot.dataSource = self
    plot.interpolation = .curved
    plot.dataLineStyle = dataLineStyle
    
    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
    let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
    let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
    xRange.length = maxTime as NSNumber
    yRange.length = (maxValue + 10.0) as NSNumber
    plotSpace.xRange = CPTPlotRange(location: 0, length: maxTime as NSNumber)
    plotSpace.yRange = CPTPlotRange(location: Constants.MinYValue as NSNumber, length: (maxValue + 10.0) as NSNumber)
    
    plotSpace.delegate = self;
    plotSpace.allowsUserInteraction = true;
    
    graph.add(plot)
    graphView.hostedGraph = graph
  }
  
  func numberOfRecords(for plot: CPTPlot) -> UInt {
    return UInt(currentSession.count)
  }
  
  func double(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Double {
    var dataPoint = ""
    
    switch (fieldEnum) {
    case 0:
      guard let sessionDataPoint = currentSession[Int(idx)] as? NSDictionary else { break }
      guard let time = sessionDataPoint["time"] else { break }
      dataPoint = time as! String
      break;
    case 1:
      guard let sessionDataPoint = currentSession[Int(idx)] as? NSDictionary else { break }
      guard let value = sessionDataPoint["value"] else { break }
      dataPoint = value as! String
      break;
    default:
      break;
    }
    
    return Double(dataPoint)!
    
  }
  
  func plotSpace(_ space: CPTPlotSpace, shouldScaleBy interactionScale: CGFloat, aboutPoint interactionPoint: CGPoint) -> Bool {
    return true
  }
  
  func plotSpace(_ space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, for coordinate: CPTCoordinate) -> CPTPlotRange? {
    
    // Here we can fix the y axis from scrolling by checking the proposed coordinate change
    if coordinate == .X {
      return newRange
    } else {
      let plotSpace: CPTXYPlotSpace = space as! CPTXYPlotSpace
      return plotSpace.yRange
    }
  }
  
}

extension ResultsDayViewController: CPTScatterPlotDataSource {
  func symbol(for plot: CPTScatterPlot, record idx: UInt) -> CPTPlotSymbol? {
    return nil
  }
}

extension ResultsDayViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    // Need control over when delegate and data source are set for the collection view
    guard let tableViewCell = cell as? SessionTableViewCell else { return }
    tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: (indexPath as NSIndexPath).section)
  }
}

extension ResultsDayViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SessionTableViewCell
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return 1
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sessionData.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    var time = ""
    let currentSessionData = sessionData[section]
    let lastShot = currentSessionData.lastObject as! NSDictionary
    if let elapsedTime = lastShot["time"] {
      if let doubleTime = Double(elapsedTime as! String) {
        time = Date.formatElapsedSecondsDouble(doubleTime.roundToHundredths())
      }
    }
    return "Session \(section+1): \(time)"
  }
}

extension ResultsDayViewController: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    // Reset plot length limits
    maxValue = 0
    maxTime = 0
    
    // Generate graph for selected session
    currentSession = sessionData[collectionView.tag]
    
    for session in currentSession {
      if let sessionDataPoint = session as? NSDictionary {
        if let stringValue = sessionDataPoint["value"] {
          let value = stringValue as! String
          if Double(value) > maxValue {
            maxValue = Double(value)!
          }
        }
      }
    }
    let lastShot = currentSession.lastObject as! NSDictionary
    if let elapsedTime = lastShot["time"] {
      if let doubleTime = Double(elapsedTime as! String) {
        maxTime = doubleTime
      }
    }
    
    self.setupGraphView()
    
    if (tableViewHeightConstraint.priority == UILayoutPriorityDefaultLow) {
      animateViews(true)
    }
  }
}

extension ResultsDayViewController: UICollectionViewDataSource {

   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ShotCollectionViewCell
    
    var time = ""
    let currentSessionData = sessionData[collectionView.tag]
    let lastShot = currentSessionData.lastObject as! NSDictionary
    if let elapsedTime = lastShot["time"] {
      if let doubleTime = Double(elapsedTime as! String) {
        time = Date.formatElapsedSecondsDouble(doubleTime.roundToHundredths())
      }
    }
    
    cell.timeLabel.text = time
    
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  
}


