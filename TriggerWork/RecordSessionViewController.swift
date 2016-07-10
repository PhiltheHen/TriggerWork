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
  var data = [String]()
  var currentIndex = 0
  var resetPlot = false
  
  // Firebase
  var ref = FIRDatabase.database().reference()
  let currentUser = FIRAuth.auth()?.currentUser
  
  // IBOutlets
  @IBOutlet weak var graphView: CPTGraphHostingView!
  @IBOutlet weak var infoView: UIView!

  @IBOutlet weak var startStopButton: StartStopButton!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    //startStopButton = StartStopButton()
    
    // Swap boolean for testing
    let save = false
    let userID = currentUser?.uid

    if save {
      /******TESTING DATA SAVE********/
      let key = ref.child("sessions").childByAutoId().key
      let session : [String : AnyObject] = ["uid" : userID!,
                     "date" : NSDate.currentDateToString(),
                     "shot_data" : [["time" : "0:00.4",
                                    "value" : "10"],
                                    ["time" : "0:00.9",
                                      "value" : "30"],
                                    ["time" : "0:01.3",
                                      "value" : "50"],
                                    ["time" : "0:02.1",
                                      "value" : "60"],
                                    ["time" : "0:02.8",
                                      "value" : "70"],
                                    ["time" : "0:03.5",
                                      "value" : "80"],
                                    ["time" : "0:04.2",
                                      "value" : "85"],
                                    ["time" : "0:05.0",
                                      "value" : "89"],
                                    ["time" : "0:06.8",
                                      "value" : "91"]]]
      
      let childUpdates = ["/sessions/\(key)" : session,
                          "/user-sessions/\(userID!)/\(key)/" : session]
      
      ref.updateChildValues(childUpdates)
      
    } else {
      /******* TESTING DATA RETRIEVAL *******/
      
      ref.child("sessions").child("-KMGd99UfXcpTufTiJi7").child("shot_data").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        
        let data = snapshot.value as! NSArray
        
        for i in 0..<data.count {
          print("key: \(data[i]["time"]!), value: \(data[i]["value"]!)")
        }
        
      })
      
    }

    
    


  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func startStopButtonPressed(sender: AnyObject) {
    if !startStopButton.selected {
      // Start data capture
      //self.ref.child("test")."
      
    } else {
      // Stop data capture
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
    resetPlot = Int(value) <= 1
    if Int(value) > 0 {
      dispatch_async(dispatch_get_main_queue(), { 
        self.infoView.hidden = true
        self.updatePlot(value)
      })
    }
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
    axisSet.xAxis?.axisLineStyle = nil
    axisSet.xAxis?.hidden = true
    axisSet.yAxis?.axisLineStyle = nil
    axisSet.yAxis?.hidden = true
    
    let plot = CPTScatterPlot()
    plot.identifier = Constants.CorePlotIdentifier
    plot.dataSource = self
    plot.interpolation = .Curved
    plot.dataLineStyle = dataLineStyle
    
    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
    plotSpace.xRange = CPTPlotRange(location: 0, length: Constants.MaxDataPoints - 2)
    plotSpace.yRange = CPTPlotRange(location: -5, length: Constants.MaxYValue)
    
    graph.addPlot(plot)
    graphView.hostedGraph = graph
  }
  
  func updatePlot(newValue: String) {
    guard let graph = graphView.hostedGraph else { return }
    guard let plot = graph.plotWithIdentifier(Constants.CorePlotIdentifier) else { return }
    
//    if resetPlot {
//      plot.deleteDataInIndexRange(NSMakeRange(0, data.count))
//      data.removeAll()
//      currentIndex = 0
//    }
    
    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
    let location = currentIndex >= Constants.MaxDataPoints ? currentIndex - Constants.MaxDataPoints + 2 : 0
    //let location = currentIndex - Constants.MaxDataPoints + 2

    let newRange = CPTPlotRange(location: location,
                                length: Constants.MaxDataPoints - 2)
    
    CPTAnimation.animate(plotSpace,
                         property: "xRange",
                         fromPlotRange: plotSpace.xRange,
                         toPlotRange: newRange,
                         duration: 0.1)
    
    currentIndex += 1
    data.append(newValue)
    plot.insertDataAtIndex(UInt(data.count - 1), numberOfRecords: 1)
    print("location: \(location)")
    print("xRange length: \(plotSpace.xRange.length)")
    print("data count: \(data.count)")
    print("")
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
      if let value = Double(data[Int(idx)]) {
        dataPoint = value
      }
      print("dataY: \(dataPoint)")
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