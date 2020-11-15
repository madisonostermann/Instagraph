//
//  SelectGraphView.swift
//  Instagraph
//
//  Created by Lannie Hough on 11/3/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct SelectGraphView: View {
    
    @ObservedObject var ocrProperties:OCRProperties
    @State var graphType:GraphType = .multiLine
    @State var selectedType = false
    
    //@State var table:[[String]] //= [["Global Temperatures", "Month", "Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"],
//                            ["Temperature", "USA Temp", "40.0", "42.2", "40.9", "50.1", "60.0", "75.3", "90.0", "83.2", "69.9", "39.1", "35.0", "32.3"],
//                            ["Temperature", "China Temp", "42.0", "45.2", "50.9", "65", "70.3", "79.0", "87.2", "85.3", "70.9", "65.1", "50.0", "40.3"],
//                            ["Temperature", "Russia Temp", "10.0", "24.2", "25.9", "34", "42.3", "50.0", "52.0", "49.2", "41.9", "30.1", "25.0", "15.3"]
//                            ]
    
    
    var body: some View {
        if !selectedType {
            ZStack {
                Color(red: 44/255, green: 47/255, blue: 51/255, opacity: 1.0).edgesIgnoringSafeArea([.top, .bottom])
                VStack {
                    HStack {
                        Spacer()
                        Text("Select graph type")//.padding()
                        Spacer()
                    }
                    .padding()
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 0.0)
                                .foregroundColor(.lightGrey).padding([.trailing, .leading])
                            RoundedRectangle(cornerRadius: 0.0).stroke(Color.yellow, lineWidth: 5.0).padding([.trailing, .leading])
                        }
                    )
                    HStack {
                        Spacer()
                        Text("Recommendation: Multi-Line")//.padding()
                        Spacer()
                    }
                    .padding()
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 0.0)
                                .foregroundColor(.lightGrey).padding([.trailing, .leading])
                            RoundedRectangle(cornerRadius: 0.0).stroke(Color.yellow, lineWidth: 5.0).padding([.trailing, .leading])
                        }
                    )
                    Spacer()
                    Button(action: {
                        haptic()
                        self.graphType = .bar
                    }, label: {
                        Text("Bar Graph")
                    }).buttonStyle(GBVButtonStyle(backColor: self.graphType == .bar ? .blue : .lightBlue))
                    Button(action: {
                        haptic()
                        self.graphType = .line
                    }, label: {
                        Text("Line Graph")
                    }).buttonStyle(GBVButtonStyle(backColor: self.graphType == .line ? .blue : .lightBlue))
                    Button(action: {
                        haptic()
                        self.graphType = .scatter
                    }, label: {
                        Text("Scatter Plot")
                    }).buttonStyle(GBVButtonStyle(backColor: self.graphType == .scatter ? .blue : .lightBlue))
                    Button(action: {
                        haptic()
                        self.graphType = .histogram
                    }, label: {
                        Text("Multi Bar Graph")
                    }).buttonStyle(GBVButtonStyle(backColor: self.graphType == .histogram ? .blue : .lightBlue))
                    Button(action: {
                        haptic()
                        self.graphType = .multiLine
                    }, label: {
                        Text("Multi Line Graph")
                    }).buttonStyle(GBVButtonStyle(backColor: self.graphType == .multiLine ? .blue : .lightBlue))
                    Spacer()
                    Button(action: {
                        haptic()
                        self.selectedType = true
                    }, label: {
                        Text("Confirm")
                    }).buttonStyle(GBVButtonStyle(backColor: .green))
                }
            }
        } else {
            GraphBuilderView(ocrProperties: self.ocrProperties, gbViewModel: GBViewModel(self.graphType))
        }
    }
}
