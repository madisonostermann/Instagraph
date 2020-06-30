//
//  ValueSliderView.swift
//  Instagraph
//
//  Created by Lannie Hough on 6/29/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct ValueSliderView: View {
    //@Binding var points:[CGPoint]
    
    @State var currentPosition: CGPoint
    @State var newPosition: CGPoint
    var offset:CGFloat
    //used for initial positioning
    var initialX: CGFloat
    var initialY: CGFloat
    //max bounds specific to this image
    let xlimit: CGFloat
    let ylimit: CGFloat
    
    @Binding var yPos:CGFloat
    
    func makeSlider() -> some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: self.currentPosition)
                path.addLine(to: .init(x: self.currentPosition.x + self.offset, y: self.currentPosition.y))
            }
            //Circle().foregroundColor(Color.blue).frame(width: 20, height: 20).position(self.currentPosition)
            .stroke(Color.red, lineWidth: CGFloat(3))
            .highPriorityGesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                //if (value.translation.width + self.newPosition.x < self.xlimit) && (value.translation.height + self.newPosition.y < self.ylimit) &&  (value.translation.width + self.newPosition.x > 0) && (value.translation.height + self.newPosition.y > 0) {
                    self.currentPosition = CGPoint(x: self.initialX, y: value.translation.height + self.newPosition.y)
                self.yPos = self.currentPosition.y
                    print(self.currentPosition)
                //}
            }.onEnded { value in
                //if (value.translation.width + self.newPosition.x < self.xlimit) && (value.translation.height + self.newPosition.y < self.ylimit) &&  (value.translation.width + self.newPosition.x > 0) && (value.translation.height + self.newPosition.y > 0) {
                    self.currentPosition = CGPoint(x: self.initialX, y: value.translation.height + self.newPosition.y)
                    self.newPosition = self.currentPosition
                //}
                })//.delayTouches()
        }
    }
    
    var body: some View {
        makeSlider()
    }
}

struct NoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension View {
    func delayTouches() -> some View {
        Button(action: {}) {
            highPriorityGesture(TapGesture())
        }
        .buttonStyle(NoButtonStyle())
    }
}
