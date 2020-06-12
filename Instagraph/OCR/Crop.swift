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
    @State var points = [CGPoint](repeating: .zero, count: 4)
    @State var newPoints = [CGPoint](repeating: .zero, count: 4)
    @State var showAlert:Bool = false
    
    func setup() {
        ocrProperties.page = "Crop"
    }

    private func getCorners() -> some View{
        ZStack {
            CropArea(points: self.$points)
            GeometryReader { geometry in
                CropCorner(currentPosition: self.$points[0], newPosition: self.$newPoints[0], initalX: 30, initalY: 30)
                CropCorner(currentPosition: self.$points[1], newPosition: self.$newPoints[1], initalX: geometry.size.width-30, initalY: 30)
                CropCorner(currentPosition: self.$points[2], newPosition: self.$newPoints[2], initalX: 30, initalY: geometry.size.height-30)
                CropCorner(currentPosition: self.$points[3], newPosition: self.$newPoints[3], initalX: geometry.size.width-30, initalY: geometry.size.height-30)
            }
        }
    }
    
    var body: some View {
        VStack {
            //Instructional message at top
            Text("Crop by tapping on edges of the table").foregroundColor(Color.black).padding().background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.blue).opacity(0.4)).padding([.vertical])//.position(x: Constants.SCREEN_WIDTH/2, y: Constants.SCREEN_HEIGHT/15)
            //Image + crop overlay
            Image(uiImage: (ocrProperties.image!)).resizable()/*.aspectRatio(1 , contentMode: .fit)*/.overlay(getCorners())
            //Process button at bottom- sends alert if crop isn't complete
            Button(action: {
                    ImageProcessingEngine(ocrProperties: self.ocrProperties).performImageRecognition()
            }) {
                Text("Process")
            }.foregroundColor(Color.black).padding().background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.blue).opacity(0.4)).padding([.vertical])//.position(x: Constants.SCREEN_WIDTH/2, y: Constants.SCREEN_HEIGHT-(Constants.SCREEN_HEIGHT/12))
        } //end of zstack
    }
}

struct CropArea: View {
    @Binding var points: [CGPoint]
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: self.points[0])
                path.addLine(to: .init(x: self.points[1].x, y: self.points[1].y))
                path.addLine(to: .init(x: self.points[3].x, y: self.points[3].y))
                path.addLine(to: .init(x: self.points[2].x, y: self.points[2].y))
                path.addLine(to: .init(x: self.points[0].x, y: self.points[0].y))
            }
            .stroke(Color.blue, lineWidth: CGFloat(2))
        }
    }
}

struct CropCorner: View {
    @Binding var currentPosition: CGPoint
    @Binding var newPosition: CGPoint
    //used for initial positioning
    var initalX: CGFloat
    var initalY: CGFloat
    
    var body: some View {
        Circle().foregroundColor(Color.blue).frame(width: 20, height: 20).offset(x: self.currentPosition.x, y: self.currentPosition.y)
        .gesture(DragGesture().onChanged { value in
            self.currentPosition = CGPoint(x: value.translation.width + self.newPosition.x, y: value.translation.height + self.newPosition.y)
        }.onEnded { value in
            self.currentPosition = CGPoint(x: value.translation.width + self.newPosition.x, y: value.translation.height + self.newPosition.y)
            self.newPosition = self.currentPosition
        }).position(CGPoint(x: 0, y: 0)).onAppear() {
            if self.initalX > 0 || self.initalY > 0 {
                self.currentPosition = CGPoint(x: self.initalX, y: self.initalY)
                self.newPosition = self.currentPosition
            }
        }
    }
}

