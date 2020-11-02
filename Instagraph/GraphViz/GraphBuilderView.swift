//
//  GraphBuilderView.swift
//  Instagraph
//
//  Created by Lannie Hough on 9/12/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

//EEnum exists in GraphEngine.swift

//Class models user going through table selection/graph creation process
//Some changes are reflected in UI & when user is finished the graphModel property is used to present a graph view
class GBViewModel: ObservableObject {
    
    private var stepIndex = 0 {
        didSet {
            currentStep = steps[stepIndex]
        }
    }
    
    private var steps:[String]
    @Published var currentStep:String
    
    var dict:[GraphType:Any] = [
        .bar: [
            "stepList": ["data", "x-label", "x-values", "y-label", "title"],
            "components": [
                "data": [],
                "x-label": "",
                "x-values": [],
                "y-label": "",
                "title": ""
            ]
        ]
    ]
    //dict
    //bar
    //   stepList
    //   components
    //   function
    //line
    
    private var graphType:GraphType
    //var graphModel:Graph!
    
    //private var building:(Bool) -> Void
    
    init(_ graphType: GraphType) {
        //switch for steps
        self.steps = (dict[graphType] as! [String:Any])["stepList"] as! [String] //for multi line rn
        self.currentStep = steps[0]
        self.graphType = graphType
        //self.building = bar
    }
    
    func submit(submitOrBack: Bool) -> GraphType? {
        if !submitOrBack && stepIndex == 0 { //can't go back
            return nil
        }
        if submitOrBack && stepIndex == steps.count-1 {
            return done()
        }
        stepIndex = submitOrBack ? stepIndex + 1 : stepIndex - 1
        switch self.graphType {
        case .bar:
            bar(submitOrBack)
        case .histogram:
            histogram(submitOrBack)
        case .line:
            line(submitOrBack)
        case .multiLine:
            multiLine(submitOrBack)
        case .scatter:
            scatter(submitOrBack)
        case .pie:
            pie(submitOrBack)
        case .none:
            return nil
        }
        return nil
    }
    
    private func done() -> GraphType {
        return self.graphType
    }
    
    private func bar(_ submitOrBack: Bool) {
        
    }
    
    private func histogram(_ submitOrBack: Bool) {
        
    }
    
    private func line(_ submitOrBack: Bool) {
        
    }
    
    private func multiLine(_ submitOrBack: Bool) {
        
    }
    
    private func scatter(_ submitOrBack: Bool) {
        
    }
    
    private func pie(_ submitOrBack: Bool) {
        
    }
    
}

struct GBVButtonStyle: ButtonStyle {
    var backColor:Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding()
            .background(backColor)
            .cornerRadius(5.0)
            .scaleEffect(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct GraphBuilderView: View {
    
    @ObservedObject var ocrProperties:OCRProperties
    @ObservedObject var gbViewModel:GBViewModel
    
    var step:String = "data"
    
    @Environment(\.colorScheme) var colorScheme
    @State var selectOrAdjust = true //true is select mode, false is adjust mode
    
    func selectOrAdjustToggle() -> some View {
        HStack {
            Button(action: {
                haptic()
                self.selectOrAdjust = true
            }, label: {
                HStack {
                    Spacer()
                    Text("Select").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                }
            }).buttonStyle(GBVButtonStyle(backColor: self.selectOrAdjust ? Color.blue : Color.lightBlue)).padding([.leading])
            
            Button(action: {
                haptic()
                self.selectOrAdjust = false
            }, label: {
                HStack {
                    Spacer()
                    Text("Adjust").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                }//.gbvButton(isPressed: $isPressed, bgColor: self.selectOrAdjust ? Color.blue : Color.lightBlue)
            }).buttonStyle(GBVButtonStyle(backColor: self.selectOrAdjust ? Color.lightBlue : Color.blue)).padding([.trailing])
        }
    }
    
    func backConfirmButtons() -> some View {
        HStack {
            Button(action: {
                haptic()
            }, label: {
                HStack {
                    Spacer()
                    Text("Back").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                }
            }).buttonStyle(GBVButtonStyle(backColor: .red)).padding([.leading])
            Button(action: {
                haptic()
            }, label: {
                HStack {
                    Spacer()
                    Text("Confirm Select").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                }
            }).buttonStyle(GBVButtonStyle(backColor: .green)).padding([.trailing])
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 44/255, green: 47/255, blue: 51/255, opacity: 1.0).edgesIgnoringSafeArea([.top, .bottom])
            VStack {
                TableView(selectOrAdjust: $selectOrAdjust)
                self.selectOrAdjustToggle()//.padding()
                self.backConfirmButtons()//.padding()
            }
            VStack {
                HStack {
                    Button(action: {
                        haptic()
                        self.ocrProperties.page = "Home"
                    }, label: {
                        Text("Home")
                    }).buttonStyle(GBVButtonStyle(backColor: .blue)).padding([.leading])
                    //Spacer()
                    HStack {
                        Spacer()
                        Text("Select the table \(step)")//.padding()
                        Spacer()
                    }
                    .padding()
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 0.0)
                                .foregroundColor(.lightGrey).padding([.trailing, .leading])
                            RoundedRectangle(cornerRadius: 0.0).stroke(Color.yellow, lineWidth: 5.0).padding([.trailing, .leading])
                            //.foregroundColor(Color.blue).padding([.trailing, .leading])
                        }
                    )
//                    Button("Home") {
//                        self.ocrProperties.page = "Home"
//                    }.padding().background(Color.blue).foregroundColor(Color.white).cornerRadius(10).padding()
//                    Spacer()
                }
                Spacer()
            }
        }
    }
}

extension Color {
    static let lightBlue = Color(red: 0.678, green: 0.847, blue: 0.902)
    static let lightGrey = Color(red: 153/255, green: 170/255, blue: 181/255)
    //67.8% red, 84.7% green and 90.2% blue
}
