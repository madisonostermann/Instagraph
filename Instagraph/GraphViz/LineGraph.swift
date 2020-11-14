//
//  LineGraph.swift
//  Instagraph
//
//  Created by Lannie Hough on 8/28/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation

struct LineGraphView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var ocrProperties: OCRProperties
    
    let base:CGFloat = 400 // Bottom edge of graph
    let start:CGFloat
    let frameHeight:CGFloat // Only square frames being used for now, represents both dimensions
    let frameWidth:CGFloat
    let yAxisLabel:String
    let xAxisLabel:String
    
    @State var multi:Bool = false
    @State var key:[String] = []
    
    init(ocrProperties: OCRProperties,
         frameHeight:CGFloat = Constants.SCREEN_WIDTH*0.7,
         frameWidth:CGFloat = Constants.SCREEN_WIDTH*0.7,
         vals: [Double], xLabels: [String],
         yAxisLabel: String,
         xAxisLabel: String,
         keys: [String]? = nil) {
        self.ocrProperties = ocrProperties
        self.frameHeight = frameHeight
        self.frameWidth = frameWidth
        self.start = (Constants.SCREEN_WIDTH-self.frameHeight)/2
        self.vals = vals; self.xLabels = xLabels
        self.xAxisLabel = xAxisLabel
        self.yAxisLabel = yAxisLabel
        if let key = keys {
            self.key = key
        }
    }
    
    let colors:[Color] = Constants.GRAPH_COLORS
    
    let vals:[Double] //= [12, 15, 15.5, 10, 25, 19.2, -5, 12]
    let xLabels:[String] //= ["January", "February", "March", "April", "May", "June", "July", "August"]
    
    func width() -> CGFloat {
        return Constants.SCREEN_WIDTH/CGFloat(self.frameWidth > Constants.SCREEN_WIDTH*0.75 ? 18 : xLabels.count*3)//vals.count*3)
    }
    
    //func dotSize() -> CGFloat {
    //  return 2.0
    //}
    
    func rotatedText(i: Int) -> some View {
        Text(self.xLabels[i]).rotationEffect(Angle(degrees: 45)).scaleEffect(0.75) // Make 0.75 dynamic size
    }
    
    func labelsText() -> some View {
        ForEach(0 ..< xLabels.count) { i in
            self.rotatedText(i: i).position(x: (self.start + 1.5*(CGFloat(i)*self.width())), y: self.base+25) // 25 is arbitrary to bring text away from bars - change to be dynamic
        }
    }
    
    func makePaths(i: Int, j: Int, sizeOfOne: CGFloat, zeroLine: CGFloat, this: Int) -> some View {
        let path = Path { path in
            path.addArc(
                center: CGPoint(x: self.start + 1.5*(CGFloat(j)*self.width()), y: (zeroLine-CGFloat(self.vals[(i*(self.vals.count/this))+j])*sizeOfOne)),
                radius: 3.0,
                startAngle: .degrees(0.0),
                endAngle: .degrees(360.0),
                clockwise: true)
        }.stroke(self.getColor(i), lineWidth: 2)
        return path
    }
    
    func makeDots(sizeOfOne: CGFloat, zeroLine: CGFloat, this: Int) -> some View { //this var might not be right - this is integer
        let dots = ForEach(0 ..< vals.count/xLabels.count) { i in
            ForEach(0 ..< (self.vals.count/(this))) { j in
                //Text(String(i))
                self.makePaths(i: i, j: j, sizeOfOne: sizeOfOne, zeroLine: zeroLine, this: this)
            }
        }
        return dots
    }
    
    func makeManyLines() -> some View {
        
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
        let this = vals.count/xLabels.count
        print(vals.count/xLabels.count)
        print(vals.count)
        
//        let dots = ForEach(0 ..< vals.count) { i in
//            Path { path in
//                path.addArc(center: CGPoint(x: self.start + 1.5*(CGFloat(i)*self.width()), y: (zeroLine-CGFloat(self.vals[i])*sizeOfOne)), radius: 4.0, startAngle: .degrees(0.0), endAngle: .degrees(360.0), clockwise: true)
//            }.foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
//        }
        let dots = self.makeDots(sizeOfOne: sizeOfOne, zeroLine: zeroLine, this: this)
//        let dots = ForEach(0 ..< vals.count/xLabels.count) { i in
//            ForEach(0 ..< (self.vals.count/(this))-1) { j in
//                Text(String(i))
//////                Path { path in
//////                    path.addArc(
//////                        center: CGPoint(x: self.start + 1.5*(CGFloat(j)*self.width()), y: (zeroLine-CGFloat(self.vals[(i*(self.vals.count/this))+j])*sizeOfOne)),
//////                        radius: 3.0,
//////                        startAngle: .degrees(0.0),
//////                        endAngle: .degrees(360.0),
//////                        clockwise: true)
//////                }.stroke(self.getColor(i), lineWidth: 2)
//            }
//        }
        
        let lines = ForEach(0 ..< vals.count/xLabels.count) { i in
            ForEach(0 ..< (self.vals.count/(this))-1) { j in
                Path { path in
                    path.move(to: CGPoint(x: self.start + 1.5*(CGFloat(j)*self.width()), y: (zeroLine-CGFloat(self.vals[(i*(self.vals.count/this))+j])*sizeOfOne)))
                    print(i+j+1)
                    path.addLine(to: CGPoint(x: self.start + 1.5*(CGFloat(j+1)*self.width()), y: (zeroLine-CGFloat(self.vals[(i*(self.vals.count/this))+j+1])*sizeOfOne)))
                }.stroke(self.getColor(i), lineWidth: 2)
                //Text(String(i))
            }
        }
        return Group {
            dots
            lines
        }
    }
    
    func getColor(_ i: Int) -> Color {
        return self.colors[i >= self.colors.count-1 ? i % self.colors.count : i]
    }
    
    func makeLines() -> some View {
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
        //if xLabels.count == vals.count {
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
        //}
        let fullViz = Group {
            dots
            line
        }
        return fullViz
//        } else {
//            return Group {
//                Text("hi")
//            }
//        }
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
            Text(String(labelVals[i])).position(x: self.start-40, y: (self.base-(CGFloat(i)*spacerNumber))).offset(x: -15.0, y: 0.0)//.scaleEffect(0.5) // -40 arbitrary
        }
    }
    
    func makeAxisLabels() -> some View {
        return Group {
            Text(self.yAxisLabel).rotationEffect(Angle(degrees: 270)).position(CGPoint(x: self.start-90, y: self.base-(self.frameHeight/2))).offset(x: -15.0, y: 0.0)
            Text(self.xAxisLabel).position(CGPoint(x: (self.start+(self.frameWidth/2)), y: self.base+70))
        }
    }
    
    func makeKeys() -> some View {
        Text("hi")
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            VStack {
                ZStack {
                    self.makeEnclosure()
                    if self.vals.count == self.xLabels.count {
                        self.makeLines()
                    } else {
                        self.makeManyLines()
                    }
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
