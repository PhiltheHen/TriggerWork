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
  
  var data = [String:String]()
  var sortedTimes = [(String, AnyObject)]()
  
  // Layout Constraints
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var graphViewHeightConstraint: NSLayoutConstraint!
  
  // Storyboard elements
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var graphView: CPTGraphHostingView!
  
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = Colors.defaultBlackColor()
    tableView.separatorStyle = .None
    loadTestData()
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
    
    // Styles
    let dataLineStyle = CPTMutableLineStyle()
    dataLineStyle.lineWidth = 3.0
    dataLineStyle.lineColor = CPTColor(CGColor: Colors.defaultGreenColor().CGColor)
    
    // Plotting Space
    let graph = CPTXYGraph(frame: CGRectZero)
    
    let axisSet = graph.axisSet as! CPTXYAxisSet
    axisSet.xAxis?.axisLineStyle = nil
    axisSet.yAxis?.axisLineStyle = nil
    
    let plot = CPTScatterPlot()
    plot.dataSource = self
    plot.interpolation = .Curved
    plot.dataLineStyle = dataLineStyle
    
    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
    let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
    let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
    guard let maxKey = data.keys.maxElement() else { return }
    guard let maxValue = data.values.maxElement() else { return }
    xRange.length = Double(maxKey)
    yRange.length = Double(maxValue)! + 10.0
    plotSpace.xRange = xRange
    plotSpace.yRange = yRange
    
    graph.addPlot(plot)
    graphView.hostedGraph = graph
  }
  
  func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
    return UInt(data.count)
  }
  
  func doubleForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> Double {
    var dataPoint = ""
    
    switch (fieldEnum) {
    case 0:
      dataPoint = sortedTimes[Int(idx)].0
      break;
    case 1:
      dataPoint = sortedTimes[Int(idx)].1 as! String
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
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return 1
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let title: String!
    switch (section) {
    case 0:
      title = "Session One: 0:43.2"
      break;
    case 1:
      title = "Session Two: 0:45.1"
      break;
    case 2:
      title = "Session Three: 0:37.9"
      break;
    default:
      title = ""
      break;
    }
    
    return title
    
  }
}

extension ResultsDayViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ShotCollectionViewCell
    
    cell.timeLabel.text = "0:03.2"
    
    return cell
  }
  
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if (tableViewHeightConstraint.priority == UILayoutPriorityDefaultLow) {
      animateViews()
    }
  }
}

extension ResultsDayViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return 5
  }
  
}


