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
            //Home Page: choose source or show graph
            if self.ocrProperties.page == "Home" {
                Button("Import Image") {
                    self.actionSheet = true
                }.actionSheet(isPresented: $actionSheet) {
                    ActionSheet(title: Text("Select Image Source"), buttons: [
                        .default(Text("Photo Library")) {
                            self.ocrProperties.page = "Photo"
                        },
                        .default(Text("Documents")) {
                            self.ocrProperties.page = "Document"
                        },
                        .default(Text("Take Photo")) {
                            self.ocrProperties.page = "Camera"
                        },
                        .cancel()
                    ])
                }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
                Button("Graph") {
                    self.ocrProperties.page = "Graph"
                }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
            //page for importing image, depends on source
            } else if self.ocrProperties.page == "Photo" {
                ImagePicker(ocrProperties: self.ocrProperties)
            } else if self.ocrProperties.page == "Document" {
                //DocumentPicker(ocrProperties: self.ocrProperties)
            } else if self.ocrProperties.page == "Camera" {
                NavigationIndicator(ocrProperties: self.ocrProperties)
            } else if self.ocrProperties.page == "Graph" {
                GraphView()
            //page for showing transformed photo + extracted text
            } else if self.ocrProperties.page == "Results" {
                VStack {
                    if showText {
                        ScrollView {Text(ocrProperties.text)}
                    } else {
                        //ocrProperties.finalImage?.resizable().padding([.vertical, .horizontal])
                        Image(uiImage: (ocrProperties.image!))
                    }
                    Spacer()
                    HStack {
                        Button(showText ? "Show Image" : "Show Text") {
                            self.showText.toggle()
                        }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
                        Button("Home") {
                            self.ocrProperties.page = "Home"
                            self.ocrProperties.source = ""
                            self.ocrProperties.image = nil
                            self.ocrProperties.finalImage = nil
                        }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
                    }
                }.padding([.vertical, .horizontal])
            }
        } //end of vstack
    }
}
