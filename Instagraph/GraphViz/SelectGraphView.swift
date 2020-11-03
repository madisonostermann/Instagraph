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
    @State var graphType:GraphType = .bar
    @State var selectedType = false
    
    
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
                        Text("Recommendation: Bar")//.padding()
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
                        self.graphType = .multiLine
                    }, label: {
                        Text("Bar Graph")
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
