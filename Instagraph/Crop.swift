//
//  Crop.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/12/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI

struct Crop: View {
    @ObservedObject var ocrProperties: OCRProperties
    @State var addPoint:Bool = false
    @State var pointPositions = [CGAffineTransform]()
    @State var points = [CGPoint]()
    @State var showAlert:Bool = false
    
    func setup() {
        ocrProperties.page = "Crop"
    }

    //TapGesture Recognizer
    //Implemented as a DragGesture Recognizer in order to detect location of tap
    //when tapped, adds a dot at the location tapped (if they aren't yet 4 dots)
    var point: some Gesture {
        DragGesture(minimumDistance: 0).onEnded { value in
            if self.pointPositions.count < 4 {
                self.pointPositions.append(CGAffineTransform(translationX: value.location.x, y: value.location.y))
                self.points.append(CGPoint(x: value.location.x, y: value.location.y))
                self.addPoint = true
            } else {
                self.addPoint = false
            }
        }
    }
    
    //NEED TO IMPLEMENT STILL
    //Drag Gesture Recognizer
    //when dragged, check to see if it's a dot being dragged
    //if so, update the location on the screen + the lines between the dots
    
    var body: some View {
        ZStack {
            Image(uiImage: (ocrProperties.image!)).resizable().gesture(point)
            //Create points & rectangle
            Path { path in
                for position in pointPositions {
                    path.addEllipse(in: CGRect(), transform: position)
                }
                if points.count > 3 {
                    path.move(to: points[3]) //last point
                    path.addLine(to: points[0])
                    path.addLine(to: points[1])
                    path.addLine(to: points[2])
                    path.addLine(to: points[3])
                }
            }.stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            
            //Instructional message at top
            Text("Crop by tapping on edges of the table").foregroundColor(Color.black).padding().background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.white).opacity(0.8)).position(x: Constants.SCREEN_WIDTH/2, y: Constants.SCREEN_HEIGHT/12)
            
            //Process button at bottom- sends alert if crop isn't complete
            Button(action: {
                if self.points.count != 4 {
                    self.showAlert = true
                } else {
                    self.showAlert = false
                    ImageProcessingEngine(ocrProperties: self.ocrProperties).performImageRecognition()
                }
            }) {
                Text("Process")
            }.foregroundColor(Color.black).padding().background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.white).opacity(0.8)).position(x: Constants.SCREEN_WIDTH/2, y: Constants.SCREEN_HEIGHT-(Constants.SCREEN_HEIGHT/12))
            .alert(isPresented: self.$showAlert) {
                    Alert(title: Text("Incomplete Crop"), message: Text("Please define 4 edges of a table before submitting for processing."), dismissButton: .default(Text("OK")))}
        } //end of zstack
    }
}
