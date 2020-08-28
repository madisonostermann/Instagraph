//
//  ValueSliderView.swift
//  Instagraph
//
//  Created by Lannie Hough on 6/29/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI
import UIKit

func haptic() {
    print("activated haptic")
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

var activateHaptic = true

struct ValueSliderView: View {
    
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
            Path { path in
                path.move(to: self.currentPosition)
                path.addLine(to: .init(x: self.currentPosition.x + self.offset, y: self.currentPosition.y))
            }
            .stroke(Color.red, lineWidth: CGFloat(3))
            .onTapGesture {
                //
            }.highPriorityGesture(DragGesture(minimumDistance: 0)//1, coordinateSpace: .local)
            .onChanged { value in
                if activateHaptic {
                    haptic()
                    activateHaptic = false
                }
                self.currentPosition = CGPoint(x: self.initialX, y: value.translation.height + self.newPosition.y)
                self.yPos = self.currentPosition.y
                    print(self.currentPosition)
            }.onEnded { value in
                if !activateHaptic {
                    activateHaptic = true
                }
                self.currentPosition = CGPoint(x: self.initialX, y: value.translation.height + self.newPosition.y)
                self.newPosition = self.currentPosition
                if self.currentPosition.y >= self.initialY {
                    self.currentPosition = CGPoint(x: self.initialX, y: self.initialY); self.newPosition = self.currentPosition
                }
                if self.currentPosition.y < (self.ylimit) {
                    print(self.ylimit)
                    self.currentPosition = CGPoint(x: self.initialX, y: self.ylimit); self.newPosition = self.currentPosition
                }
                self.yPos = self.currentPosition.y
                })
    }
    
    var body: some View {
        makeSlider()
    }
}
