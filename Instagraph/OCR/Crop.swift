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
import UIKit

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
                CropCorner(currentPosition: self.$points[0], newPosition: self.$newPoints[0], initialX: 0, initialY: 0, xlimit: geometry.size.width, ylimit: geometry.size.height) //top left
                CropCorner(currentPosition: self.$points[1], newPosition: self.$newPoints[1], initialX: geometry.size.width, initialY: 0, xlimit: geometry.size.width, ylimit: geometry.size.height) //top right
                CropCorner(currentPosition: self.$points[2], newPosition: self.$newPoints[2], initialX: geometry.size.width, initialY: geometry.size.height, xlimit: geometry.size.width, ylimit: geometry.size.height) //bottom right
                CropCorner(currentPosition: self.$points[3], newPosition: self.$newPoints[3], initialX: 0, initialY: geometry.size.height, xlimit: geometry.size.width, ylimit: geometry.size.height) //bottom left
            }
        }
    }
    
    func crop() {
        let cropPath = Path { path in
            path.move(to: self.points[0])
            path.addLine(to: .init(x: self.points[1].x, y: self.points[1].y))
            path.addLine(to: .init(x: self.points[2].x, y: self.points[2].y))
            path.addLine(to: .init(x: self.points[3].x, y: self.points[3].y))
            path.addLine(to: .init(x: self.points[0].x, y: self.points[0].y))
        }
        let cropArea = cropPath.cgPath.boundingBox
        let imageViewScale = max(ocrProperties.image!.size.width/UIScreen.main.bounds.width, ocrProperties.image!.size.width/UIScreen.main.bounds.height)
        let cropRect = CGRect(x:cropArea.integral.origin.x * imageViewScale,
                              y:cropArea.integral.origin.y * imageViewScale,
                              width:cropArea.integral.size.width * imageViewScale,
                              height:cropArea.integral.size.height * imageViewScale)
        let cgimg = self.ocrProperties.image?.cgImage!
        let croppedCGImage = cgimg?.cropping(to: cropRect)
        self.ocrProperties.image = UIImage(cgImage: croppedCGImage!)
        ImageProcessingEngine(ocrProperties: self.ocrProperties).performImageRecognition()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                //Image + crop overlay
                Image(uiImage: (self.ocrProperties.image!)).resizable().aspectRatio(contentMode: .fit).overlay(self.getCorners())
                // Crop Button
                Button (action : { self.crop() }) {
                    Text("Process")
                }.foregroundColor(Color.black).padding(10).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.blue).opacity(0.4))
            } //end of vstack
        }
    }
}

struct CropArea: View {
    @Binding var points: [CGPoint]
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: self.points[0])
                path.addLine(to: .init(x: self.points[1].x, y: self.points[1].y))
                path.addLine(to: .init(x: self.points[2].x, y: self.points[2].y))
                path.addLine(to: .init(x: self.points[3].x, y: self.points[3].y))
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
                print("XLIMIT: ", self.xlimit)
                print("YLIMIT: ", self.ylimit)
                if self.initialX > 0 || self.initialY > 0 {
                    self.currentPosition = CGPoint(x: self.initialX, y: self.initialY)
                    self.newPosition = self.currentPosition
                }
        }
    }
}
