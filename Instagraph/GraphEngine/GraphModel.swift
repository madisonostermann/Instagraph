//
//  GraphModel.swift
//  InstagraphEngine
//
//  Created by Lannie Hough on 5/15/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import Foundation

class Graph {
    let title:String
    let xAxisLabel:String
    let yAxisLabel:String
    let data:[[Double]]
    
    init(title: String, xAxisLabel: String, yAxisLabel: String, data: [[Double]]) {
        self.title = title == "" ? "My Graph" : title
        self.xAxisLabel = xAxisLabel == "" ? "x-Axis" : xAxisLabel
        self.yAxisLabel = yAxisLabel == "" ? "y-Axis" : yAxisLabel
        self.data = data
    }
}

class BarGraph: Graph {
    let xAxisValues:[String]
    //yAxisValues are produced dynamically when graphing from data
    init(title: String, xAxisLabel: String, yAxisLabel: String, data: [[Double]], xAxisValues: [String]) {
        self.xAxisValues = xAxisValues
        super.init(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data)
    }
}

class LineGraph: Graph {
    let xAxisValues:[String]
    //yAxisValues are produced dynamically when graphing from data
    init(title: String, xAxisLabel: String, yAxisLabel: String, data: [[Double]], xAxisValues: [String]) {
        self.xAxisValues = xAxisValues
        super.init(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data)
    }
}

//class Histogram
//class MultiLine
//class Pie

class ScatterPlot: Graph {
    // x-Axis & y-Axis values are generated dynamically
    override init(title: String, xAxisLabel: String, yAxisLabel: String, data: [[Double]]) {
        super.init(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data)
    }
}
