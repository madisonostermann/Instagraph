//
//  BarGraph.swift
//  Instagraph
//
//  Created by Lannie Hough on 8/28/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation

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
    
    init(ocrProperties: OCRProperties,
         frameHeight:CGFloat = Constants.SCREEN_WIDTH*0.7,
         frameWidth:CGFloat = Constants.SCREEN_WIDTH*0.7,
         bars: [Double],
         barLabels: [String],
         yAxisLabel: String, xAxisLabel: String) {
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
            // Button(action: {
            //   print(i)
            //}) {
            Path { path in
                path.move(to: CGPoint(x: (self.start + 1.5*(CGFloat(i)*self.width())), y: zeroLine)) // Bars are 0.5 bars apart
                path.addLine(to: CGPoint(x: self.start + 1.5*(CGFloat(i)*self.width()), y: (zeroLine-CGFloat(self.bars[i])*sizeOfOne)))
            }.stroke(self.colors[i >= self.colors.count-1 ? i % self.colors.count : i], lineWidth: self.width()) // Conditional keeps colors on a loop, once new colors run out start over again
            //}
        }//.buttonStyle(BorderlessButtonStyle())
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
    
    @State var originalOffset:CGFloat = 70.0
    @State var offset:CGFloat = 70.0
    
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    self.makeEnclosure()
                    self.makeBars()
                    self.labelsText()
                    self.makeValueLabels()
                    self.makeAxisLabels()
                }.offset(x: self.offset, y: 0).simultaneousGesture(DragGesture().onChanged { value in
                    let distanceTraveled = value.location.x - value.startLocation.x
                    self.offset = self.originalOffset
                    self.offset = self.offset + distanceTraveled
                }.onEnded { value in
                    self.originalOffset = self.offset
                })
                ValueSliderView(currentPosition: self.startPoint, newPosition: self.endPoint, offset: self.frameWidth, initialX: self.startPoint.x, initialY: self.base, xlimit: self.startPoint.x+self.frameWidth, ylimit: self.base-self.frameHeight, yPos: self.$yPos).offset(x: self.offset, y: 0)
            }
            Text(String(screenPosToGraphVal(sizeOfOne: {
                let largestValue = bars.max()!
                let smallestValue = bars.min()!
                let labelValues = makeLabelValues(largest: largestValue, smallest: smallestValue)
                return self.frameHeight/CGFloat(labelValues.max()!-labelValues.min()!)
            }(), zeroLine: {
                let largestValue = bars.max()!
                let smallestValue = bars.min()!
                let labelValues = makeLabelValues(largest: largestValue, smallest: smallestValue)
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
            }(), yPos: self.yPos)))
        }
    }
}
