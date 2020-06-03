//
//  GraphView.swift
//  Instagraph
//
//  Created by Lannie Hough on 5/29/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI
import UIKit

struct GraphView: View {
    
    let base:CGFloat = 400 // Bottom edge of graph
    let start:CGFloat
    let frameHeight:CGFloat // Only square frames being used for now, represents both dimensions
    //let frameWidth:CGFloat
    
    init() { //Adjust for variable input later - REVIEW
        self.frameHeight = Constants.SCREEN_WIDTH*0.75
        self.start = (Constants.SCREEN_WIDTH-self.frameHeight)/2
    }
    
    let colors:[Color] = Constants.GRAPH_COLORS
    
    let bars:[Double] = [12, 15, 15.5, 10.5, 25, 19.2, 5, 12]
    let barLabels:[String] = ["January", "February", "March", "April", "May", "June", "July", "August"]
    
    func scale() -> CGFloat {
        let scaleFactor:CGFloat = self.frameHeight/CGFloat(self.bars.max()!)
        return scaleFactor
    }
    
    func width() -> CGFloat { // Determines width of bars
        return Constants.SCREEN_WIDTH/CGFloat(self.frameHeight > Constants.SCREEN_WIDTH*0.75 ? 6*3 : bars.count*3) // Sets minimum bar width if graph extends beyond screen
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
        ForEach(0 ..< bars.count) { i in
            Path { path in
                path.move(to: CGPoint(x: (self.start + 1.5*(CGFloat(i)*self.width())), y: self.base)) // Bars are 0.5 bars apart
                path.addLine(to: CGPoint(x: self.start + 1.5*(CGFloat(i)*self.width()), y: (self.base-CGFloat(self.bars[i])*self.scale()))) // 10 is arbitrary to make bars larger - change to be dynamic
            }.stroke(self.colors[i >= self.colors.count-1 ? i % self.colors.count : i], lineWidth: self.width()) // Conditional keeps colors on a loop, once new colors run out start over again
        }
    }
    
    func makeEnclosure() -> some View {
        Group {
            Path { path in // Horizontal bounding line
                path.move(to: CGPoint(x: self.start-20, y: self.base+3)) // 20 and 3 are arbitrary, make dynamic
                path.addLine(to: CGPoint(x: self.frameHeight+self.start, y: self.base+3))
            }.stroke(Color.black, lineWidth: 3)
            Path { path in // Vertical bounding line
                path.move(to: CGPoint(x: self.start-20, y: self.base+3))
                path.addLine(to: CGPoint(x: self.start-20, y: (self.base-frameHeight)))
            }.stroke(Color.black, lineWidth: 3)
        }
    }
    
    func makeValueLabels() -> some View {
        Text("hi")
    }
    
    func makeValueLabelValues(largest: Double, smallest: Double) -> [Double] { // Give numbers that represent labels on the y-axis
        let range = largest - smallest
        var labels:[Double] = []
        let magnitude:Int = Int(log10(range).rounded(.down))
        let originalIncrement:Double = pow(10, Double(magnitude-1)) // For magnitude 0, increment is 1 - for magnitude 1, increment is 10
        var actualIncrement:Double = 0
        checkLoop: for i in 1 ... 10 {
            let testIncrement = originalIncrement*Double(i)
            if 10*testIncrement >= range { // Changed largest to range
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
        while i >= 0 {
            if labels[i] > largest+actualIncrement {
                labels.remove(at: i)
            } else {
                break
            }
            i -= 1
        }
        return labels
    }
    
    var body: some View {
        ZStack {
            self.makeEnclosure()
            self.makeBars()
            self.labelsText()
        }
    }
}

