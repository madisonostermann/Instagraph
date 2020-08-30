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
    @State private var actionSheet: Bool = false
    //left/right have same x
    //top/bottom have same y
    @State var top: CGFloat = 0
    @State var bottom: CGFloat = 0
    @State var left: CGFloat = 0
    @State var right: CGFloat = 0
    @State var topNew: CGFloat = 0
    @State var bottomNew: CGFloat = 0
    @State var leftNew: CGFloat = 0
    @State var rightNew: CGFloat = 0
    
    func setup() {
        ocrProperties.page = "Crop"
    }
    
    private func getCorners() -> some View{
        ZStack {
            GeometryReader { geometry in
                CropCorner(initialX: 0, initialY: 0, xlimit: geometry.size.width, ylimit: geometry.size.height, currentX: self.$left, currentY: self.$top, newX: self.$leftNew, newY: self.$topNew) //top left
                CropCorner(initialX: geometry.size.width, initialY: 0, xlimit: geometry.size.width, ylimit: geometry.size.height, currentX: self.$right, currentY: self.$top, newX: self.$rightNew, newY: self.$topNew) //top right
                CropCorner(initialX: geometry.size.width, initialY: geometry.size.height, xlimit: geometry.size.width, ylimit: geometry.size.height, currentX: self.$right, currentY: self.$bottom, newX: self.$rightNew, newY: self.$bottomNew) //bottom right
                CropCorner(initialX: 0, initialY: geometry.size.height, xlimit: geometry.size.width, ylimit: geometry.size.height, currentX: self.$left, currentY: self.$bottom, newX: self.$leftNew, newY: self.$bottomNew) //bottom left
            }
            CropArea(left: self.$left, right: self.$right, top: self.$top, bottom: self.$bottom)
        }
    }
    
    func crop() {
        let cropPath = Path { path in
            path.move(to: CGPoint(x: self.left, y: self.top)) //top left
            path.addLine(to: .init(x: self.right, y: self.top)) //top right
            path.addLine(to: .init(x: self.right, y: self.bottom)) //bottom right
            path.addLine(to: .init(x: self.left, y: self.bottom)) //bottom left
            path.addLine(to: .init(x: self.left, y: self.top)) //top left
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
                Button("Use Different Image") {
                    self.actionSheet = true
                }.actionSheet(isPresented: self.$actionSheet) {
                    ActionSheet(title: Text("Select Image Source"), buttons: [
                        .default(Text("Photo Library")) {
                            self.ocrProperties.page = "Photo"
                        },
//                        .default(Text("Documents")) {
//                            self.ocrProperties.page = "Document"
//                        },
                        .default(Text("Take Photo")) {
                            self.ocrProperties.page = "Camera"
                        },
                        .cancel()
                    ])
                }.foregroundColor(Color.black).padding(10).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.blue).opacity(0.4))
                //Image + crop overlay
                Image(uiImage: (self.ocrProperties.image!)).resizable().aspectRatio(contentMode: .fit).overlay(self.getCorners())
                // Crop Button
                Button("Process") {
                    self.crop()
                }.foregroundColor(Color.black).padding(10).background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.blue).opacity(0.4))
            }.padding([.top, .bottom]) //end of vstack
        }
    }
}

struct CropArea: View {
    @Binding var left: CGFloat
    @Binding var right: CGFloat
    @Binding var top: CGFloat
    @Binding var bottom: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: self.left, y: self.top)) //top left
                path.addLine(to: .init(x: self.right, y: self.top)) //top right
                path.addLine(to: .init(x: self.right, y: self.bottom)) //bottom right
                path.addLine(to: .init(x: self.left, y: self.bottom)) //bottom left
                path.addLine(to: .init(x: self.left, y: self.top)) //top left
            }
            .stroke(Color.blue, lineWidth: CGFloat(2))
        }
    }
}

struct CropCorner: View {
    //used for initial positioning
    var initialX: CGFloat
    var initialY: CGFloat
    //max bounds specific to this image
    let xlimit: CGFloat
    let ylimit: CGFloat
    
    @Binding var currentX: CGFloat
    @Binding var currentY: CGFloat
    @Binding var newX: CGFloat
    @Binding var newY: CGFloat
    
    var body: some View {
        Circle().foregroundColor(Color.blue).frame(width: 20, height: 20).offset(x: self.currentX, y: self.currentY)
            .gesture(DragGesture().onChanged { value in
                if (value.translation.width + self.newX < self.xlimit) && (value.translation.height + self.newY < self.ylimit) &&  (value.translation.width + self.newX > 0) && (value.translation.height + self.newY > 0) {
                    self.currentX = value.translation.width + self.newX
                    self.currentY = value.translation.height + self.newY
                }
            }.onEnded { value in
                if (value.translation.width + self.newX < self.xlimit) && (value.translation.height + self.newY < self.ylimit) &&  (value.translation.width + self.newX > 0) && (value.translation.height + self.newY > 0) {
                    self.currentX = value.translation.width + self.newX
                    self.currentY = value.translation.height + self.newY
                    self.newX = self.currentX
                    self.newY = self.currentY
                }
            }).position(CGPoint(x: 0, y: 0)).onAppear() {
                if self.initialX > 0 || self.initialY > 0 {
                    self.currentX = self.initialX
                    self.currentY = self.initialY
                    self.newX = self.currentX
                    self.newY = self.currentY
                }
        }
    }
}
