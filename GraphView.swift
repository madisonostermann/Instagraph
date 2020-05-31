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
    let frameHeight:CGFloat// = Constants.SCREEN_WIDTH*0.75 // Only square frames being used for now
    
    init() {
        self.frameHeight = Constants.SCREEN_WIDTH*0.75
        self.start = (Constants.SCREEN_WIDTH-self.frameHeight)/2
    }
    
    let colors:[Color] = [Color.blue, Color.red, Color.purple, Color.yellow, Color.green, Color.orange]
    
    let bars:[Double] = [12, 15, 15.5, 10.5, 25, 19.2]
    let barLabels:[String] = ["January", "February", "March", "April", "May", "June"]
    
    func width() -> CGFloat {
        return Constants.SCREEN_WIDTH/CGFloat((bars.count*3))
    }
    
    func rotatedText(i: Int) -> some View {
        //VStack(alignment: .trailing) {
        Text(self.barLabels[i]).rotationEffect(Angle(degrees: 45)).scaleEffect(0.75)
        //}
    }
    
    func labelsText() -> some View {
        ForEach(0 ..< bars.count) { i in
            self.rotatedText(i: i).position(x: (self.start + 1.5*(CGFloat(i)*self.width())), y: self.base+25)
        }
    }
    
    func makeBars() -> some View {
        ForEach(0 ..< bars.count) { i in
            Path { path in
                path.move(to: CGPoint(x: (self.start + 1.5*(CGFloat(i)*self.width())), y: self.base))
                path.addLine(to: CGPoint(x: self.start + 1.5*(CGFloat(i)*self.width()), y: (self.base-CGFloat(self.bars[i]*10))))
            }.stroke(self.colors[i], lineWidth: self.width())
        }
    }
    
    func makeEnclosure() -> some View {
        Group {
            Path { path in // Horizontal bounding line
                path.move(to: CGPoint(x: self.start-20, y: self.base+3))
                path.addLine(to: CGPoint(x: self.frameHeight+self.start, y: self.base+3))
            }.stroke(Color.black, lineWidth: 3)
            Path { path in // Vertical bounding line
                path.move(to: CGPoint(x: self.start-20, y: self.base+3))
                path.addLine(to: CGPoint(x: self.start-20, y: (self.base-frameHeight)))
            }.stroke(Color.black, lineWidth: 3)
        }
    }
    
    var body: some View {
        ZStack {
            self.makeEnclosure()
            self.makeBars()
            self.labelsText()
        }
    }
}
