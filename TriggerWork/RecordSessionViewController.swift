//
//  RecordSessionViewController.swift
//  TriggerWork
//
//  Created by Phil Henson on 4/10/16.
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


class RecordSessionViewController: UIViewController {
  
  // Data
  var data = [[String : String]]()
  var interruptIndices = [UInt]()
  var currentIndex = 0
  var resetPlot = false
  var currentYMax: Int = Constants.MaxYValue
  
  // Core Plot
  var graph : CPTGraph?
  var plot : CPTPlot?
  
  // Timer
  var startTime: TimeInterval = Date.timeIntervalSinceReferenceDate
  var currentTime: TimeInterval = 0
  var fetchTimer: RepeatingTimer?
  var stopwatch: Stopwatch?
  
  // Firebase
  let firManager = FIRDataManager()
  
  // IBOutlets
  @IBOutlet weak var graphView: CPTGraphHostingView!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var startStopButton: StartStopButton!
  @IBOutlet weak var stopwatchLabel: UILabel!
  @IBOutlet weak var connectedTriggerLabel: UILabel!

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Unsure if this is needed
    //startStopButton = StartStopButton()
    
    stopwatchLabel.isHidden = true;
    stopwatch = Stopwatch(self.stopwatchLabel)
    
    if let peripheralName = btDiscoverySharedInstance.connectedPeripheralName {
      connectedTriggerLabel.text = "Connected to " + peripheralName
    } else {
      connectedTriggerLabel.text = "Connected to Bluetooth Trigger"
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // Setup timer for reading characteristic from bluetooth
    fetchTimer = RepeatingTimer(Constants.BLEDataUpdateInterval) {
      if let service = btDiscoverySharedInstance.bleService {
        service.fetchBroadcastingCharacteristicValue()
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if (fetchTimer != nil) {
      fetchTimer?.cancel()
    }
  }
  
  // MARK: - IBActions
  @IBAction func startStopButtonPressed(_ sender: AnyObject) {
    if !startStopButton.isSelected {
      // Clear plot and prepare to save data
      self.clearPlot()
      startTime = Date.timeIntervalSinceReferenceDate
      
      // Show stopwatch as it updates with the BLE data fetch
      stopwatchLabel.textColor = Colors.defaultRedColor()
      stopwatchLabel.isHidden = false
      stopwatch?.start()
    } else {
      
      // Change color of stopwatch to indicate session time is completed
      stopwatch?.stop()
      stopwatchLabel.textColor = Colors.defaultGreenColor()

      // Save data and clear plot
      self.saveDataAndClearPlot()
    }
    
    startStopButton.isSelected = !startStopButton.isSelected
  }
  
  // MARK: - UI Settings
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return .lightContent
  }
}

// MARK: - BTService Delegate
extension RecordSessionViewController: BTServiceDelegate {
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupGraphView()
    infoView.isHidden = false
    
    // Set the delegate so the view can respond to changes broadcasted values
    if let service = btDiscoverySharedInstance.bleService {
      service.delegate = self
    }
  }

  func didUpdateTriggerValue(value: String, interrupt: Bool) {
    // Append new values to data array for plotting
    DispatchQueue.main.async(execute: {
      self.infoView.isHidden = true
      self.updatePlot(value, interrupt: interrupt)
    })

  }
}

// MARK: - Core Plot Data Source
extension RecordSessionViewController: CPTPlotDataSource {
  func setupGraphView() {
    
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
    
    let plot = CPTScatterPlot()
    plot.identifier = Constants.CorePlotIdentifier as (NSCoding & NSCopying & NSObjectProtocol)?
    plot.dataSource = self
    plot.interpolation = .curved
    plot.dataLineStyle = dataLineStyle
    
    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
    plotSpace.xRange = CPTPlotRange(location: 0, length: (Constants.MaxDataPoints - 2) as NSNumber)
    plotSpace.yRange = CPTPlotRange(location: Constants.MinYValue as NSNumber, length: Constants.MaxYValue as NSNumber)
    
    graph.add(plot)
    graphView.hostedGraph = graph
    
    self.plot = plot
    self.graph = graph
  }
  
  // Helpers
  func clearPlot() {
    if let _ = plot {
      // Remove data from array and clear plot space
      plot!.deleteData(inIndexRange: NSMakeRange(0, data.count))
      data.removeAll()
      currentIndex = 0
      currentYMax = Constants.MaxYValue
    }
  }
  
  func saveDataAndClearPlot() {
    firManager.saveSessionWithShotData(data)
    self.clearPlot()
  }
  
  
  func updatePlot(_ newValue: String, interrupt: Bool) {
    
    // Add interrupt index to array for easier searching
    if interrupt {
      let dataPoint = UInt(data.count)
      
      // Shot detection is finicky. Need to ignore any recent shots detected and only display one
      
      if interruptIndices.count == 0 {
        interruptIndices.append(UInt(data.count))
      } else if Int(dataPoint) - Int(interruptIndices.last!) > 20 {
        interruptIndices.append(UInt(data.count))
      } else {
        // We don't want to update the plot when this method is called from the interrupt
        return;
      }
    }
    
    // Optional reset when data is < 1. Currently unused
    //    if resetPlot {
    //      plot.deleteDataInIndexRange(NSMakeRange(0, data.count))
    //      data.removeAll()
    //      currentIndex = 0
    //    }
    
    // If both graph and plot exist, plot points
    if let _ = graph, let _ = plot {
      
      // Shift X Range
      let plotSpace = graph!.defaultPlotSpace as! CPTXYPlotSpace
      let location = currentIndex >= Constants.MaxDataPoints ? currentIndex - Constants.MaxDataPoints + 2 : 0
      let newXRange = CPTPlotRange(location: location as NSNumber,
                                   length: (Constants.MaxDataPoints - 2) as NSNumber)
      
      CPTAnimation.animate(plotSpace,
                           property: "xRange",
                           from: plotSpace.xRange,
                           to: newXRange,
                           duration: CGFloat(Constants.BLEDataUpdateInterval)) // want the animation time to be the same as the update interval
      
      // Scale Y Range if necessary - Want the plot to max out 4/5 of the way up
      if (Float(newValue) > Float(currentYMax) * (4/5)) {
        
        currentYMax = Int(Float(newValue)! * 5/4)
        
        let newYRange = CPTPlotRange(location: Constants.MinYValue as NSNumber, length: NSNumber(value: currentYMax as Int))
        
        CPTAnimation.animate(plotSpace,
                             property: "yRange",
                             from: plotSpace.yRange,
                             to: newYRange,
                             duration: CGFloat(Constants.BLEDataUpdateInterval))
        
      }
      
      
      
      currentIndex += 1
      
      // Want to save the time for each data point as it comes in
      currentTime = Date.timeIntervalSinceReferenceDate
      let elapsedTime = (currentTime - startTime).roundToHundredths()
      
      data.append(["time" : "\(Double(elapsedTime))", "value" : newValue, "interrupt" : String(interrupt)])
      plot!.insertData(at: UInt(data.count - 1), numberOfRecords: 1)
      
     // print("location: \(location)")
     // print("xRange length: \(plotSpace.xRange.length)")
     // print("data count: \(data.count)")
     // print("")
    }
  }
  
  func numberOfRecords(for plot: CPTPlot) -> UInt {
    return UInt(data.count)
  }
  
  func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
    var dataPoint: Double = 0.0
    
    switch (fieldEnum) {
    case 0:
      dataPoint = Double(Int(idx) + currentIndex - data.count)
      //print("dataX: \(dataPoint)")
      break;
    case 1:
      if let stringValue = data[Int(idx)]["value"] {
        if let value = Double(stringValue) {
          dataPoint = value
          //print("dataY: \(dataPoint)")
        }
      }
      break;
    default:
      break;
    }
    return dataPoint as AnyObject?
  }
}

// MARK: - Scatter Plot Data Source
extension RecordSessionViewController: CPTScatterPlotDataSource {
  func symbol(for plot: CPTScatterPlot, record idx: UInt) -> CPTPlotSymbol? {
    
    if interruptIndices.contains(idx) {
      return ShotFiredPlotSymbol()
    }
    
    return nil
  }
}
