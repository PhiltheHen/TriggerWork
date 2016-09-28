//
//  ShotFiredPlotSymbol.swift
//  TriggerWork
//
//  Created by Phil Henson on 9/27/16.
//  Copyright © 2016 Lost Nation R&D. All rights reserved.
//

import UIKit
import CorePlot

class ShotFiredPlotSymbol: CPTPlotSymbol {

  override init() {
    super.init()
    setupSymbol()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupSymbol()
  }
  
  func setupSymbol() {
    let symbolLineStyle = CPTMutableLineStyle()
    let symbolColor = CPTColor.init(cgColor: Colors.defaultRedColor().cgColor)
    symbolLineStyle.lineColor = symbolColor
    lineStyle = symbolLineStyle
    symbolType = CPTPlotSymbolType.cross
    size = CGSize(width: 30, height: 30)
    fill = CPTFill(color: symbolColor)
  }
  
}
