//
//  ContentView.swift
//  Instagraph
//
//  Created by Madison Gipson on 5/25/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI
import UIKit

struct NavigationIndicator: UIViewControllerRepresentable {
    @ObservedObject var ocrProperties: OCRProperties
    typealias UIViewControllerType = ARCameraView
    
    func makeUIViewController(context: Context) -> ARCameraView {
        return ARCameraView(ocrProperties: ocrProperties)
    }
    func updateUIViewController(_ uiViewController: NavigationIndicator.UIViewControllerType, context: UIViewControllerRepresentableContext<NavigationIndicator>) { }
}
// 1. Home Page (Import Image Options)
// 2. Image Picker or Camera (or later, Document)
// 3. Image Processing (correct perspective & clean up image)
// 4. Crop (manually)
// 5. OCR & Cell Detection & Text Sorting
// 6. Graph
struct ContentView: View {
    @ObservedObject var ocrProperties: OCRProperties
    @State private var present: Bool = false
    @State private var actionSheet: Bool = false
    @State private var showText: Bool = true //if false, show image
    @State private var screenSize = UIScreen.main.bounds
    
    var body: some View {
        return VStack {
            // 1. Home Page (Import Image Options)
            if self.ocrProperties.page == "Home" {
                Button("Import Image") {
                    self.actionSheet = true
                }.actionSheet(isPresented: $actionSheet) {
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
//                Button("Graph") {
//                    self.ocrProperties.page = "Graph"
//                }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10)
            } else if self.ocrProperties.page == "Photo" {
                ImagePicker(ocrProperties: self.ocrProperties) // 2. Image Picker or Camera (or later, Document)
            } else if self.ocrProperties.page == "Camera" {
                NavigationIndicator(ocrProperties: self.ocrProperties) // 2. Image Picker or Camera (or later, Document)
//          } else if self.ocrProperties.page == "Document" {
//                DocumentPicker(ocrProperties: self.ocrProperties)
            } else if self.ocrProperties.page == "Crop" {
                Crop(ocrProperties: self.ocrProperties) // 4. Crop (manually)
            } else if self.ocrProperties.page == "Graph" {
                AnyGraphView(self.ocrProperties, table: self.ocrProperties.dataArray/*SceneDelegate.demoBar*/) // 6. Graph
            }
        } //end of vstack
    }
}
