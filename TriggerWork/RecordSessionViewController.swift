//
//  RecordSessionViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 4/10/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit
import CorePlot

class RecordSessionViewController: UIViewController {
  
  // Data
  var data = [[String : String]]()
  var currentIndex = 0
  var resetPlot = false
  var currentYMax: Int = Constants.MaxYValue
  
  // Core Plot
  var graph : CPTGraph?
  var plot : CPTPlot?
  
  // Timer
  var startTime: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
  var currentTime: NSTimeInterval = 0
  var fetchTimer: RepeatingTimer?
  
  // Firebase
  let firManager = FIRDataManager()
  
  // IBOutlets
  @IBOutlet weak var graphView: CPTGraphHostingView!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var startStopButton: StartStopButton!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Unsure if this is needed
    //startStopButton = StartStopButton()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // Setup timer for reading characteristic from bluetooth
    fetchTimer = RepeatingTimer(Constants.BLEDataUpdateInterval) {
      if let service = btDiscoverySharedInstance.bleService {
        service.fetchBroadcastingCharacteristicValue()
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    if (fetchTimer != nil) {
      fetchTimer?.cancel()
    }
  }
  
  // MARK: - IBActions
  @IBAction func startStopButtonPressed(sender: AnyObject) {
    if !startStopButton.selected {
      // Clear plot and prepare to save data
      self.clearPlot()
      startTime = NSDate.timeIntervalSinceReferenceDate()
    } else {
      // Save data and clear plot
      self.saveDataAndClearPlot()
    }
    
    startStopButton.selected = !startStopButton.selected
  }
  
  // MARK: - UI Settings
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
}

// MARK: - BTService Delegate
extension RecordSessionViewController: BTServiceDelegate {
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    setupGraphView()
    infoView.hidden = false
    
    // Set the delegate so the view can respond to changes broadcasted values
    if let service = btDiscoverySharedInstance.bleService {
      service.delegate = self
    }
  }
  
  func didUpdateTriggerValue(value: String) {
    // Append new values to data array for plotting
    
    dispatch_async(dispatch_get_main_queue(), {
      self.infoView.hidden = true
      self.updatePlot(value)
    })
    
    
    // The following was used for only plotting values greater than 0
    // Right now we want continuous plotting regarless of magnitude
    // Might return to this in the future
    
    /*
        resetPlot = Int(value) <= 1
        if Int(value) > 0 {
          dispatch_async(dispatch_get_main_queue(), {
            self.infoView.hidden = true
            self.updatePlot(value)
          })
        }
     */
  }
}

// MARK: - Core Plot Data Source
extension RecordSessionViewController: CPTPlotDataSource {
  func setupGraphView() {
    
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
    
    let plot = CPTScatterPlot()
    plot.identifier = Constants.CorePlotIdentifier
    plot.dataSource = self
    plot.interpolation = .Curved
    plot.dataLineStyle = dataLineStyle
    
    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
    plotSpace.xRange = CPTPlotRange(location: 0, length: Constants.MaxDataPoints - 2)
    plotSpace.yRange = CPTPlotRange(location: Constants.MinYValue, length: Constants.MaxYValue)
    
    graph.addPlot(plot)
    graphView.hostedGraph = graph
    
    self.plot = plot
    self.graph = graph
  }
  
  // Helpers
  func clearPlot() {
    if let _ = plot {
      // Remove data from array and clear plot space
      plot!.deleteDataInIndexRange(NSMakeRange(0, data.count))
      data.removeAll()
      currentIndex = 0
      currentYMax = Constants.MaxYValue
    }
  }
  
  func saveDataAndClearPlot() {
    firManager.saveSessionWithShotData(data)
    self.clearPlot()
  }
  
  func updatePlot(newValue: String) {
    
    // Optional reset when data is < 1. Currently unused
    //    if resetPlot {
    //      plot.deleteDataInIndexRange(NSMakeRange(0, data.count))
    //      data.removeAll()
    //      currentIndex = 0
    //    }
    
    // If both graph and plot exist, plot points
    if let _ = graph, _ = plot {
      
      // Shift X Range
      let plotSpace = graph!.defaultPlotSpace as! CPTXYPlotSpace
      let location = currentIndex >= Constants.MaxDataPoints ? currentIndex - Constants.MaxDataPoints + 2 : 0
      let newXRange = CPTPlotRange(location: location,
                                  length: Constants.MaxDataPoints - 2)
      
      CPTAnimation.animate(plotSpace,
                           property: "xRange",
                           fromPlotRange: plotSpace.xRange,
                           toPlotRange: newXRange,
                           duration: CGFloat(Constants.BLEDataUpdateInterval)) // want the animation time to be the same as the update interval
      
      // Scale Y Range if necessary - Want the plot to max out 4/5 of the way up
      if (Float(newValue) > Float(currentYMax) * (4/5)) {
    
        currentYMax = Int(Float(newValue)! * 5/4)
        
        let newYRange = CPTPlotRange(location: Constants.MinYValue, length: NSNumber(integer: currentYMax))
        
        CPTAnimation.animate(plotSpace,
                             property: "yRange",
                             fromPlotRange: plotSpace.yRange,
                             toPlotRange: newYRange,
                             duration: CGFloat(Constants.BLEDataUpdateInterval))

      }
      

      
      currentIndex += 1
      
      // Want to save the time for each data point as it comes in
      currentTime = NSDate.timeIntervalSinceReferenceDate()
      let elapsedTime = (currentTime - startTime).roundToHundredths()
      
      data.append(["time" : "\(Double(elapsedTime))",
                   "value" : newValue])
      plot!.insertDataAtIndex(UInt(data.count - 1), numberOfRecords: 1)
      print("location: \(location)")
      print("xRange length: \(plotSpace.xRange.length)")
      print("data count: \(data.count)")
      print("")
    }
  }

  func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
    return UInt(data.count)
  }
  
  func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
    var dataPoint: Double = 0.0
    
    switch (fieldEnum) {
    case 0:
      dataPoint = Double(Int(idx) + currentIndex - data.count)
      print("dataX: \(dataPoint)")
      break;
    case 1:
      if let stringValue = data[Int(idx)]["value"] {
        if let value = Double(stringValue) {
          dataPoint = value
          print("dataY: \(dataPoint)")
        }
      }
      break;
    default:
      break;
    }
    return dataPoint
  
  }
}

// MARK: - Scatter Plot Data Source
extension RecordSessionViewController: CPTScatterPlotDataSource {
  func symbolForScatterPlot(plot: CPTScatterPlot, recordIndex idx: UInt) -> CPTPlotSymbol? {
    return nil
  }
}