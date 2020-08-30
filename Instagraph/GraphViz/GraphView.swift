//
//  GraphView.swift
//  Instagraph
//
//  Created by Lannie Hough on 5/29/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI
import UIKit

struct AnyGraphView: View {
    var graphEngine:GraphEngine
    var ocrProperties:OCRProperties
    
    init(_ ocrProperties: OCRProperties, table: [[String]]) {
        self.ocrProperties = ocrProperties
        self.graphEngine = GraphEngine(table: table)
    }
    
    func whatType() -> some View {
        let result = self.graphEngine.determineGraphType()
        return Group {
            if result.0 == .failure {
                Text("Couldn't build graph")
            }
            if result.0 != .failure && result.1[0] is LineGraph {
                LineGraphView(ocrProperties: ocrProperties, vals: (result.1[0] as! LineGraph).data, xLabels: (result.1[0] as! LineGraph).xAxisValues, yAxisLabel: (result.1[0] as! LineGraph).yAxisLabel, xAxisLabel: (result.1[0] as! LineGraph).xAxisLabel)
            }
            if result.0 != .failure && result.1[0] is BarGraph {
                BarGraphView(ocrProperties: ocrProperties, bars: (result.1[0] as! BarGraph).data, barLabels: (result.1[0] as! BarGraph).xAxisValues, yAxisLabel: (result.1[0] as! BarGraph).yAxisLabel, xAxisLabel: (result.1[0] as! BarGraph).xAxisLabel)
            }
        }
    }
    
    var body: some View {
        VStack {
            Button("New Graph") {
                self.ocrProperties.page = "Home"
            }.foregroundColor(Color.black).padding(10).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.blue).opacity(0.4))
            self.whatType()
        }
    }
}

struct LineGraphView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ocrProperties: OCRProperties
    
    let base:CGFloat = 400 // Bottom edge of graph
    let start:CGFloat
    let frameHeight:CGFloat // Only square frames being used for now, represents both dimensions
    let frameWidth:CGFloat
    let yAxisLabel:String
    let xAxisLabel:String
    
    init(ocrProperties: OCRProperties, frameHeight:CGFloat = Constants.SCREEN_WIDTH*0.7, frameWidth:CGFloat = Constants.SCREEN_WIDTH*0.7, vals: [Double], xLabels: [String], yAxisLabel: String, xAxisLabel: String) {
        self.ocrProperties = ocrProperties
        self.frameHeight = frameHeight
        self.frameWidth = frameWidth
        self.start = (Constants.SCREEN_WIDTH-self.frameHeight)/2
        self.vals = vals; self.xLabels = xLabels
        self.xAxisLabel = xAxisLabel
        self.yAxisLabel = yAxisLabel
    }
    
    let vals:[Double] //= [12, 15, 15.5, 10, 25, 19.2, -5, 12]
    let xLabels:[String] //= ["January", "February", "March", "April", "May", "June", "July", "August"]
    
    func width() -> CGFloat {
        return Constants.SCREEN_WIDTH/CGFloat(self.frameWidth > Constants.SCREEN_WIDTH*0.75 ? 18 : vals.count*3)
    }
    
    //func dotSize() -> CGFloat {
      //  return 2.0
    //}
    
    func rotatedText(i: Int) -> some View {
        Text(self.xLabels[i]).rotationEffect(Angle(degrees: 45)).scaleEffect(0.75) // Make 0.75 dynamic size
    }
    
    func labelsText() -> some View {
        ForEach(0 ..< vals.count) { i in
            self.rotatedText(i: i).position(x: (self.start + 1.5*(CGFloat(i)*self.width())), y: self.base+25) // 25 is arbitrary to bring text away from bars - change to be dynamic
        }
    }
    
    func makeDots() -> some View {
        let largestValue = vals.max()!
        let smallestValue = vals.min()!
        let labelValues = makeLabelValues(largest: largestValue, smallest: smallestValue)
        let sizeOfOne = self.frameHeight/CGFloat(labelValues.max()!-labelValues.min()!) // Vertical height of one integer unit
        let zeroLine:CGFloat = {
            let labelIncSize:CGFloat = self.frameHeight/CGFloat(labelValues.count-1)
            // Get number of increments before reaching 0 label
            var numIncs:Int = 1
            loop: for i in 0 ..< labelValues.count {
                if labelValues[i] == 0 || labelValues[i] == 0.0 {
                    numIncs = i
                    break loop
                }
            }
            return self.base-(labelIncSize*CGFloat(numIncs))
        }()
        let dots = ForEach(0 ..< vals.count) { i in
            Path { path in
                path.addArc(center: CGPoint(x: self.start + 1.5*(CGFloat(i)*self.width()), y: (zeroLine-CGFloat(self.vals[i])*sizeOfOne)), radius: 4.0, startAngle: .degrees(0.0), endAngle: .degrees(360.0), clockwise: true)
            }.foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
        }
        //var line = Path()//.stroke(Color.white, lineWidth: self.width())
        let line = ForEach(0 ..< vals.count-1) { i in//for i in 0 ..< vals.count {
            Path { path in
                path.move(to: CGPoint(x: self.start + 1.5*(CGFloat(i)*self.width()), y: (zeroLine-CGFloat(self.vals[i])*sizeOfOne)))
                path.addLine(to: CGPoint(x: self.start + 1.5*(CGFloat(i+1)*self.width()), y: (zeroLine-CGFloat(self.vals[i+1])*sizeOfOne)))
            }.stroke(self.colorScheme == .dark ? Color.white : Color.black, lineWidth: 2)
        }
        let fullViz = Group {
            dots
            line
        }
        return fullViz
    }
    
    func makeEnclosure() -> some View {
        Group {
            Path { path in // Horizontal bounding line
                path.move(to: CGPoint(x: self.start-20, y: self.base+3)) // 20 and 3 are arbitrary, make dynamic
                path.addLine(to: CGPoint(x: self.frameHeight+self.start, y: self.base+3))
            }.stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 3)
            Path { path in // Vertical bounding line
                path.move(to: CGPoint(x: self.start-20, y: self.base+3))
                path.addLine(to: CGPoint(x: self.start-20, y: (self.base-frameHeight)))
            }.stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 3)
        }
    }
    
    func makeValueLabels() -> some View {
        let labelVals = makeLabelValues(largest: vals.max()!, smallest: vals.min()!)
        let spacerNumber:CGFloat = self.frameHeight/CGFloat(labelVals.count-1)
        return ForEach(0 ..< labelVals.count) { i in
            Text(String(labelVals[i])).position(x: self.start-40, y: (self.base-(CGFloat(i)*spacerNumber))) // -40 arbitrary
        }
    }
    
    func makeAxisLabels() -> some View {
        return Group {
            Text(self.yAxisLabel).rotationEffect(Angle(degrees: 270)).position(CGPoint(x: self.start-90, y: self.base-(self.frameHeight/2)))
            Text(self.xAxisLabel).position(CGPoint(x: (self.start+(self.frameWidth/2)), y: self.base+70))
        }
    }
    
    var body: some View {
        ScrollView(.horizontal) {
        VStack {
            ZStack {
                self.makeEnclosure()
                self.makeDots()
                self.labelsText()
                self.makeValueLabels()
                self.makeAxisLabels()
            }.offset(x: 70, y: 0)
            /*Button("Home") {
                self.ocrProperties.page = "Home"
                self.ocrProperties.source = ""
                self.ocrProperties.image = nil
                self.ocrProperties.finalImage = nil
            }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10)*/
        }
        }
    }
    
}

struct BarGraphView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ocrProperties: OCRProperties
    
    var startPoint:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var endPoint:CGPoint = CGPoint(x: 0.0, y: 0.0)

    
    let base:CGFloat = 400 // Bottom edge of graph
    let start:CGFloat
    let frameHeight:CGFloat // Only square frames being used for now, represents both dimensions
    let frameWidth:CGFloat
    let yAxisLabel:String
    let xAxisLabel:String
    
    init(ocrProperties: OCRProperties, frameHeight:CGFloat = Constants.SCREEN_WIDTH*0.7, frameWidth:CGFloat = Constants.SCREEN_WIDTH*0.7, bars: [Double], barLabels: [String], yAxisLabel: String, xAxisLabel: String) {
        self.ocrProperties = ocrProperties
        self.frameHeight = frameHeight
        self.frameWidth = frameWidth
        self.start = (Constants.SCREEN_WIDTH-self.frameHeight)/2
        self.bars = bars; self.barLabels = barLabels
        self.xAxisLabel = xAxisLabel
        self.yAxisLabel = yAxisLabel
        self.startPoint = CGPoint(x: self.start-20, y: self.base)
        self.endPoint = CGPoint(x: (self.start)+self.frameWidth, y: self.base)
        self.yPos = self.base
        //UIScrollView.appearance().bounces = false
    }
    
    let colors:[Color] = Constants.GRAPH_COLORS
    
    let bars:[Double] //= [12, 15, 15.5, 10, 25, 19.2, -5, 12]
    let barLabels:[String] //= ["January", "February", "March", "April", "May", "June", "July", "August"]
    
    func width() -> CGFloat { // Determines width of bars
        return Constants.SCREEN_WIDTH/CGFloat(self.frameWidth > Constants.SCREEN_WIDTH*0.75 ? 6*3 : bars.count*3) // Sets minimum bar width if graph extends beyond screen
    }
    
    func rotatedText(i: Int) -> some View {
        Text(self.barLabels[i]).rotationEffect(Angle(degrees: 45)).scaleEffect(0.75) // Make 0.75 dynamic size
    }
    
    func labelsText() -> some View {
        ForEach(0 ..< bars.count) { i in
            self.rotatedText(i: i).position(x: (self.start + 1.5*(CGFloat(i)*self.width())), y: self.base+25) // 25 is arbitrary to bring text away from bars - change to be dynamic
        }
    }
    
    func makeBars() -> some View {
        let largestValue = bars.max()!
        let smallestValue = bars.min()!
        let labelValues = makeLabelValues(largest: largestValue, smallest: smallestValue)
        let sizeOfOne = self.frameHeight/CGFloat(labelValues.max()!-labelValues.min()!) // Vertical height of one integer unit
        let zeroLine:CGFloat = {
            let labelIncSize:CGFloat = self.frameHeight/CGFloat(labelValues.count-1)
            // Get number of increments before reaching 0 label
            var numIncs:Int = 1
            loop: for i in 0 ..< labelValues.count {
                if labelValues[i] == 0 || labelValues[i] == 0.0 {
                    numIncs = i
                    break loop
                }
            }
            return self.base-(labelIncSize*CGFloat(numIncs))
        }()
        return ForEach(0 ..< bars.count) { i in
            Path { path in
                path.move(to: CGPoint(x: (self.start + 1.5*(CGFloat(i)*self.width())), y: zeroLine)) // Bars are 0.5 bars apart
                path.addLine(to: CGPoint(x: self.start + 1.5*(CGFloat(i)*self.width()), y: (zeroLine-CGFloat(self.bars[i])*sizeOfOne)))
            }.stroke(self.colors[i >= self.colors.count-1 ? i % self.colors.count : i], lineWidth: self.width()) // Conditional keeps colors on a loop, once new colors run out start over again
        }
    }
    
    func makeEnclosure() -> some View {
        Group {
            Path { path in // Horizontal bounding line
                path.move(to: CGPoint(x: self.start-20, y: self.base+3)) // 20 and 3 are arbitrary, make dynamic
                path.addLine(to: CGPoint(x: self.frameHeight+self.start, y: self.base+3))
            }.stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 3)
            Path { path in // Vertical bounding line
                path.move(to: CGPoint(x: self.start-20, y: self.base+3))
                path.addLine(to: CGPoint(x: self.start-20, y: (self.base-frameHeight)))
            }.stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 3)
        }
    }
    
    func makeValueLabels() -> some View {
        let labelVals = makeLabelValues(largest: bars.max()!, smallest: bars.min()!)
        let spacerNumber:CGFloat = self.frameHeight/CGFloat(labelVals.count-1)
        return ForEach(0 ..< labelVals.count) { i in
            Text(String(labelVals[i])).position(x: self.start-40, y: (self.base-(CGFloat(i)*spacerNumber))) // -40 arbitrary
        }
    }
    
    func makeAxisLabels() -> some View {
        return Group {
            Text(self.yAxisLabel).rotationEffect(Angle(degrees: 270)).position(CGPoint(x: self.start-90, y: self.base-(self.frameHeight/2)))
            Text(self.xAxisLabel).position(CGPoint(x: (self.start+(self.frameWidth/2)), y: self.base+70))
        }
    }
    
    @State var yPos:CGFloat = 0.0
    
    var body: some View {
        VStack {
            //ScrollView(.horizontal) {
        ZStack {
        ScrollView(.horizontal) {
            ZStack {
            HStack {
                //Text("Y axis label").rotationEffect(Angle(degrees: 270))
                VStack {
                    ZStack {
                        self.makeEnclosure()
                        self.makeBars()
                        self.labelsText()
                        self.makeValueLabels()
                        self.makeAxisLabels()
                        //ValueSliderView(currentPosition: self.startPoint, newPosition: self.endPoint, offset: self.frameWidth, initialX: self.startPoint.x, initialY: self.base, xlimit: self.startPoint.x+self.frameWidth, ylimit: self.base+self.frameHeight)
                    }.offset(x: 70, y: 0)
                //Text("X axis label")
            /*Button("Home") {
                self.ocrProperties.page = "Home"
                self.ocrProperties.source = ""
                self.ocrProperties.image = nil
                self.ocrProperties.finalImage = nil
            }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10)*/
                }
            }
                Button(action:{print("doing a thing")}) {
                    ValueSliderView(currentPosition: self.startPoint, newPosition: self.endPoint, offset: self.frameWidth, initialX: self.startPoint.x, initialY: self.base, xlimit: self.startPoint.x+self.frameWidth, ylimit: self.base-self.frameHeight, yPos: self.$yPos).offset(x: 70, y: 0)//.onTapGesture {
                        //print("hi")
                    }//.gesture(DragGesture(minimumDistance: 0).onChanged { value in
                      //  print("dragging")
                        //}).delayTouches()
                //}
            }
        } //ScrollView end
            //ValueSliderView(currentPosition: self.startPoint, newPosition: self.endPoint, offset: self.frameWidth, initialX: self.startPoint.x, initialY: self.base, xlimit: self.startPoint.x+self.frameWidth, ylimit: self.base-self.frameHeight, yPos: self.$yPos).offset(x: 70, y: 0)
        }
            //}
            Text(String(screenPosToGraphVal(sizeOfOne: {
                let largestValue = bars.max()!
                let smallestValue = bars.min()!
                let labelValues = makeLabelValues(largest: largestValue, smallest: smallestValue)
                return self.frameHeight/CGFloat(labelValues.max()!-labelValues.min()!)
            }(), zeroLine: {
                let largestValue = bars.max()!
                let smallestValue = bars.min()!
                let labelValues = makeLabelValues(largest: largestValue, smallest: smallestValue)
                //let sizeOfOne = self.frameHeight/CGFloat(labelValues.max()!-labelValues.min()!) // Vertical height of one integer unit
                let zeroLine:CGFloat = {
                    let labelIncSize:CGFloat = self.frameHeight/CGFloat(labelValues.count-1)
                    // Get number of increments before reaching 0 label
                    var numIncs:Int = 1
                    loop: for i in 0 ..< labelValues.count {
                        if labelValues[i] == 0 || labelValues[i] == 0.0 {
                            numIncs = i
                            break loop
                        }
                    }
                    return self.base-(labelIncSize*CGFloat(numIncs))
                }()
                return zeroLine
            }(), yPos: self.yPos)))//Double(self.yPos)))
    }
    }
}

func screenPosToGraphVal(sizeOfOne: CGFloat, zeroLine: CGFloat, yPos: CGFloat) -> Double {
    //size of one is CGFloat value for how much screen space one unit takes up
    //zeroline is where zero is
    var distanceFromZero = zeroLine-yPos
    var value = distanceFromZero/sizeOfOne
    return Double(value)
    //return 0.0
}

func makeLabelValues(largest: Double, smallest: Double) -> [Double] { // Give numbers that represent labels on the y-axis
    let range = smallest >= 0 ? largest : largest - smallest
    var labels:[Double] = []
    let magnitude:Int = Int(log10(range).rounded(.down))
    let originalIncrement:Double = pow(10, Double(magnitude-1)) // Ex: For magnitude 0, increment is 1 -- for magnitude 1, increment is 10
    var actualIncrement:Double = 0
    checkLoop: for i in 1 ... 10 {
        let testIncrement = originalIncrement*Double(i)
        if 10*testIncrement > range { // Changed largest to range
            actualIncrement = testIncrement
            break checkLoop
        }
    }
    buildLabels: for i in 0 ... 10 {
        if smallest >= 0 { // Start at 0
            labels.append(Double(i)*actualIncrement)
        } else { // Find where to start - negative number < smallest that falls on an increment
            var lastInc:Double = 0
            while lastInc > smallest {
                lastInc -= actualIncrement
            }
            for _ in 0 ... 10 {
                labels.append(lastInc)
                lastInc += actualIncrement
            }
            break buildLabels
        }
    }
    var i = labels.count-1
    while i >= 0 { // Make sure no extra whitespace
        if labels[i] > largest+actualIncrement {
            labels.remove(at: i)
        } else {
            break
        }
        i -= 1
    }
    return labels
}

