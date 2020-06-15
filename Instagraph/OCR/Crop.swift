//
//  Crop.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/12/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import CoreGraphics

struct Crop: View {
    @ObservedObject var ocrProperties: OCRProperties
    @State var addPoint:Bool = false
    @State var points = [CGPoint](repeating: .zero, count: 4)
    @State var newPoints = [CGPoint](repeating: .zero, count: 4)
    @State var showAlert:Bool = false
    @State var imageWidth:CGFloat!
    @State var imageHeight:CGFloat!
    @State var maxX:CGFloat = -1
    @State var maxY:CGFloat = -1
    
    func setup() {
        ocrProperties.page = "Crop"
    }
    
    func crop() {
        let cropPath = Path { path in
            path.move(to: self.points[0])
            path.addLine(to: .init(x: self.points[1].x, y: self.points[1].y))
            path.addLine(to: .init(x: self.points[3].x, y: self.points[3].y))
            path.addLine(to: .init(x: self.points[2].x, y: self.points[2].y))
            path.addLine(to: .init(x: self.points[0].x, y: self.points[0].y))
        }
        
        let imageViewScale = max(self.ocrProperties.image!.size.width/maxX, self.ocrProperties.image!.size.height/maxY)
        let cropArea = cropPath.cgPath.boundingBox
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropArea.origin.x * imageViewScale,
                              y:cropArea.origin.y * imageViewScale,
                              width:cropArea.size.width * imageViewScale,
                              height:cropArea.size.height * imageViewScale)
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = self.ocrProperties.image!.cgImage?.cropping(to:cropZone)
        else { return }
        self.ocrProperties.image = UIImage(cgImage: cutImageRef)
        ImageProcessingEngine(ocrProperties: self.ocrProperties).performImageRecognition()
    }

    private func getCorners() -> some View{
        ZStack {
            CropArea(points: self.$points)
            GeometryReader { geometry in
                CropCorner(currentPosition: self.$points[0], newPosition: self.$newPoints[0], initialX: 0, initialY: 0, xlimit: geometry.size.width, ylimit: geometry.size.height, maxX: self.$maxX, maxY: self.$maxX)
                CropCorner(currentPosition: self.$points[1], newPosition: self.$newPoints[1], initialX: geometry.size.width, initialY: 0, xlimit: geometry.size.width, ylimit: geometry.size.height, maxX: self.$maxX, maxY: self.$maxX)
                CropCorner(currentPosition: self.$points[2], newPosition: self.$newPoints[2], initialX: 0, initialY: geometry.size.height, xlimit: geometry.size.width, ylimit: geometry.size.height, maxX: self.$maxX, maxY: self.$maxX)
                CropCorner(currentPosition: self.$points[3], newPosition: self.$newPoints[3], initialX: geometry.size.width, initialY: geometry.size.height, xlimit: geometry.size.width, ylimit: geometry.size.height, maxX: self.$maxX, maxY: self.$maxX)
            }
        }
    }
    
    var body: some View {
        ZStack {
            //Image + crop overlay
            Image(uiImage: (ocrProperties.image!)).resizable()/*.aspectRatio(1 , contentMode: .fit)*/.padding(.horizontal, 10).overlay(getCorners())
            /*Path { path in
                path.move(to: self.points[0])
                path.addLine(to: .init(x: self.points[1].x, y: self.points[1].y))
                path.addLine(to: .init(x: self.points[3].x, y: self.points[3].y))
                path.addLine(to: .init(x: self.points[2].x, y: self.points[2].y))
                path.addLine(to: .init(x: self.points[0].x, y: self.points[0].y))
            }.stroke(Color.red, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))*/
            //Process button at bottom- sends alert if crop isn't complete
            Button(action: {
                self.crop()
            }) {
                Text("Process")
            }.foregroundColor(Color.black).padding(10).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.blue).opacity(0.4)).position(x: Constants.SCREEN_WIDTH/2, y: Constants.SCREEN_HEIGHT-(Constants.SCREEN_HEIGHT/15))//.padding([.vertical])
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
    var initialX: CGFloat
    var initialY: CGFloat
    //max bounds specific to this image
    let xlimit: CGFloat
    let ylimit: CGFloat
    //max X and Y, used for cropping
    @Binding var maxX: CGFloat
    @Binding var maxY: CGFloat
    
    var body: some View {
        Circle().foregroundColor(Color.blue).frame(width: 20, height: 20).offset(x: self.currentPosition.x, y: self.currentPosition.y)
        .gesture(DragGesture().onChanged { value in
            if (value.translation.width + self.newPosition.x < self.xlimit) && (value.translation.height + self.newPosition.y < self.ylimit) &&  (value.translation.width + self.newPosition.x > 0) && (value.translation.height + self.newPosition.y > 0) {
                self.currentPosition = CGPoint(x: value.translation.width + self.newPosition.x, y: value.translation.height + self.newPosition.y)
            }
        }.onEnded { value in
            if (value.translation.width + self.newPosition.x < self.xlimit) && (value.translation.height + self.newPosition.y < self.ylimit) &&  (value.translation.width + self.newPosition.x > 0) && (value.translation.height + self.newPosition.y > 0) {
                self.currentPosition = CGPoint(x: value.translation.width + self.newPosition.x, y: value.translation.height + self.newPosition.y)
                self.newPosition = self.currentPosition
            }
        }).position(CGPoint(x: 0, y: 0)).onAppear() {
            if self.maxX == -1 {
                self.maxX = self.xlimit
            }
            if self.maxY == -1 {
                self.maxY = self.ylimit
            }
            if self.initialX > 0 || self.initialY > 0 {
                self.currentPosition = CGPoint(x: self.initialX, y: self.initialY)
                self.newPosition = self.currentPosition
            }
        }
    }
}

