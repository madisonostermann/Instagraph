//
//  GraphModel.swift
//  InstagraphEngine
//
//  Created by Lannie Hough on 5/15/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import Foundation

class Graph {//: Equatable {
//    static func == (lhs: Graph, rhs: Graph) -> Bool {
//        <#code#>
//    }
    
    let title:String
    let xAxisLabel:String
    let yAxisLabel:String
    //let data:[Double]
    
    init(title: String, xAxisLabel: String, yAxisLabel: String) {
        self.title = title == "" ? "My Graph" : title
        self.xAxisLabel = xAxisLabel == "" ? "x-Axis" : xAxisLabel
        self.yAxisLabel = yAxisLabel == "" ? "y-Axis" : yAxisLabel
        //self.data = data
    }
}

class BarGraph: Graph, Equatable {
    static func == (lhs: BarGraph, rhs: BarGraph) -> Bool {
        if lhs.title != rhs.title {
            return false
        } else if lhs.xAxisLabel != rhs.xAxisLabel {
            return false
        } else if lhs.yAxisLabel != rhs.yAxisLabel {
            return false
        } else if lhs.xAxisValues != rhs.xAxisValues {
            return false
        } else if lhs.data != rhs.data {
            return false
        }
        return true
    }
    
    let xAxisValues:[String]
    let data:[Double]
    //yAxisValues are produced dynamically when graphing from data
    init(title: String, xAxisLabel: String, yAxisLabel: String, data: [Double], xAxisValues: [String]) {
        self.xAxisValues = xAxisValues
        self.data = data
        super.init(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel)
    }
}

class LineGraph: Graph, Equatable {
    static func == (lhs: LineGraph, rhs: LineGraph) -> Bool {
        if lhs.title != rhs.title {
            return false
        } else if lhs.xAxisLabel != rhs.xAxisLabel {
            return false
        } else if lhs.yAxisLabel != rhs.yAxisLabel {
            return false
        } else if lhs.xAxisValues != rhs.xAxisValues {
            return false
        } else if lhs.data != rhs.data {
            return false
        }
        return true
    }
    
    let xAxisValues:[String]
    let data:[Double]
    var keys:[String] = []
    //yAxisValues are produced dynamically when graphing from data
    init(title: String, xAxisLabel: String, yAxisLabel: String, data: [Double], xAxisValues: [String], keys: [String]? = nil) {
        self.xAxisValues = xAxisValues
        self.data = data
        if let key = keys {
            self.keys = key
        }
        super.init(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel)
    }
}

//class Histogram
//class MultiLine
class PieChart: Graph {
    
}

class ScatterPlot: Graph, Equatable {
    static func == (lhs: ScatterPlot, rhs: ScatterPlot) -> Bool {
        if lhs.title != rhs.title {
            return false
        } else if lhs.xAxisLabel != rhs.xAxisLabel {
            return false
        } else if lhs.yAxisLabel != rhs.yAxisLabel {
            return false
        } else if lhs.data != rhs.data {
            return false
        }
        return true
    }
    
    let data:[[Double]]
    // x-Axis & y-Axis values are generated dynamically
    init(title: String, xAxisLabel: String, yAxisLabel: String, data: [[Double]]) {
        self.data = data
        super.init(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel)
    }
}
