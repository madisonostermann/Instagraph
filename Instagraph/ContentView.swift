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

struct ContentView: View {
    @ObservedObject var ocrProperties: OCRProperties
    @State private var present: Bool = false
    @State private var actionSheet: Bool = false
    @State private var showText: Bool = true //if false, show image
    @State private var screenSize = UIScreen.main.bounds
    
    var body: some View {
        VStack {
            if ocrProperties.image != nil && ocrProperties.text != "" {
                VStack {
                    if showText {
                        ScrollView {Text(ocrProperties.text)}
                    } else {
                        ocrProperties.finalImage?.resizable().padding([.vertical, .horizontal])
                    }
                    Spacer()
                    HStack {
                        Button(showText ? "Show Image" : "Show Text") {
                            self.showText.toggle()
                        }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
                        Button("Choose New Image") {
                            self.present = false
                            self.ocrProperties.source = ""
                            self.ocrProperties.image = nil
                        }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
                    }
                }.padding([.vertical, .horizontal])
            } else {
                Button("Import Image") {
                    self.actionSheet = true
                }.actionSheet(isPresented: $actionSheet) {
                    ActionSheet(title: Text("Select Image Source"), buttons: [
                        .default(Text("Photo Library")) {
                            self.present = true
                            self.ocrProperties.source = "Photo"
                        },
                        .default(Text("Documents")) {
                            self.present = true
                            self.ocrProperties.source = "Document"
                        },
                        .default(Text("Take Photo")) {
                            self.present = true
                            self.ocrProperties.source = "Camera"
                        },
                        .cancel()
                    ])
                }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
                Button("Graph") {
                    self.present = true
                    self.ocrProperties.source = "Graph"
                }
            }
        }.sheet(isPresented: self.$present) {
            if self.ocrProperties.source == "Photo" {
                ImagePicker(ocrProperties: self.ocrProperties)
            } else if self.ocrProperties.source == "Document" {
                DocumentFinder(ocrProperties: self.ocrProperties)
            } else if self.ocrProperties.source == "Camera" {
                 NavigationIndicator(ocrProperties: self.ocrProperties)
            } else if self.ocrProperties.source == "Graph" {
                GraphView()
            }
        }
    }
}
