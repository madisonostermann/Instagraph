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
                Button("Graph") {
                    self.ocrProperties.page = "Graph"
                }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10)
                Button("Table") {
                    self.ocrProperties.page = "Table"
                }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10)
//                Button("Test") {
//                    Testing.runTestingPipeline()
//                }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10)
//                Button("Test 2") {
//                    //TestTables.testTables()
//                    TestTables.test2Tables()
//                }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10)
//            } else if self.ocrProperties.page == "Photo" {
//                ImagePicker(ocrProperties: self.ocrProperties) // 2. Image Picker or Camera (or later, Document)
//            } else if self.ocrProperties.page == "Camera" {
//                NavigationIndicator(ocrProperties: self.ocrProperties) // 2. Image Picker or Camera (or later, Document)
//          } else if self.ocrProperties.page == "Document" {
//                DocumentPicker(ocrProperties: self.ocrProperties)
//            } else if self.ocrProperties.page == "Crop" {
//                Crop(ocrProperties: self.ocrProperties) // 4. Crop (manually)
//            } else if self.ocrProperties.page == "Graph" {
//                //LineGraphView(ocrProperties: self.ocrProperties, vals: [90.0, 83.2, 69.9, 50.1, 40.0, 35.3, 86.0, 83.2, 74.9, 65, 42.3, 40.0, 54.0, 53.2, 45.9, 42, 44.4, 35.0], xLabels: ["July", "Aug", "Sep", "Oct", "Nov", "Dec"], yAxisLabel: "Temperature", xAxisLabel: "Months")
//                AnyGraphView(self.ocrProperties, table: self.ocrProperties.contentColumns)//table: SceneDelegate.demoBar) // 6. Graph
            } else if self.ocrProperties.page == "Table" {
                //let gbvm = GBViewModel(.multiLine)
//                let table:[[String]] = [["Global Temperatures", "Month", "Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"],
//                                        ["Temperature", "USA Temp", "40.0", "42.2", "40.9", "50.1", "60.0", "75.3", "90.0", "83.2", "69.9", "39.1", "35.0", "32.3"],
//                                        ["Temperature", "China Temp", "42.0", "45.2", "50.9", "65", "70.3", "79.0", "87.2", "85.3", "70.9", "65.1", "50.0", "40.3"],
//                                        ["Temperature", "Russia Temp", "10.0", "24.2", "25.9", "34", "42.3", "50.0", "52.0", "49.2", "41.9", "30.1", "25.0", "15.3"]
//                                        ]
//                let ge:GraphEngine = GraphEngine(table: table)
//                let result = ge.checkTemporalComplex(table: table)
//                var gType:GraphType = .bar
//                if result {
//                    gType = .mulitLine
//                } else {
//                    gType = .bar
//                }
                SelectGraphView(ocrProperties: self.ocrProperties)//, graphType: gType, table: table)
                //GraphBuilderView(ocrProperties: self.ocrProperties, gbViewModel: GBViewModel(.bar))
//                ZStack {
//                    Color(red: 44/255, green: 47/255, blue: 51/255, opacity: 1.0).edgesIgnoringSafeArea([.top, .bottom])
//                    GraphBuilderView(ocrProperties: self.ocrProperties)
//                    VStack {
//                    HStack {
//                        Button("Home") {
//                            self.ocrProperties.page = "Home"
//                        }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10).padding()
//                        Spacer()
//                    }
//                        Spacer()
//                    }
////                    GraphBuilderView()//TestView()//TableView()
//                }
            }
        } //end of vstack
    }
}

