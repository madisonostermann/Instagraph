//
//  GraphBuilderView.swift
//  Instagraph
//
//  Created by Lannie Hough on 9/12/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

//EEnum exists in GraphEngine.swift

class SelectedSingleton {
    static var selected:[String] = []
}

//Class models user going through table selection/graph creation process
//Some changes are reflected in UI & when user is finished the graphModel property is used to present a graph view
class GBViewModel: ObservableObject {
    
    var finished = false
    
    private var stepIndex = 0 {
        didSet {
            if stepIndex < steps.count { //prevent ioob
                currentStep = steps[stepIndex]
            }
        }
    }
    
    private var steps:[String]
    @Published var currentStep:String
    
    var dict:[GraphType:Any] = [
        .bar: [
            "stepList": ["data", "x-label", "x-values", "y-label", "title"]
        ],
        .line: [
            "stepList": ["data", "x-label", "x-values", "y-label", "title"]
        ],
        .scatter: [
            "stepList": ["data", "x-label", "y-label", "title"]
        ],
        .multiLine: [
            "stepList": ["data", "x-label", "x-values", "y-label", "keys", "title"]
        ]
    ]
    
    //Possible properties for a graph model - not all will be used for some types
    var data:[String] = []
    var xLabel:String = ""
    var yLabel:String = ""
    var xValues:[String] = []
    var title:String = ""
    var keys:[String] = []
    
    var graphType:GraphType
    
    init(_ graphType: GraphType) {
        self.steps = (dict[graphType] as! [String:Any])["stepList"] as! [String]
        self.currentStep = steps[0]
        self.graphType = graphType
    }
    
    func submit(submitOrBack: Bool, selection: [String]) -> Graph? {
        if !submitOrBack && stepIndex == 0 { //can't go back
            return nil
        }
        
        if !submitOrBack {
            stepIndex -= 1
            return nil
        }
        
        if submitOrBack {
            switch self.currentStep {
            case "data":
                self.data = selection
            case "x-label":
                self.xLabel = selection[0]
            case "y-label":
                self.yLabel = selection[0]
            case "title":
                self.title = selection[0]
            case "keys":
                self.keys = selection
            case "x-values":
                self.xValues = selection
            default:
                print("default")
            }
        }
        
        stepIndex += 1
        
        if submitOrBack && stepIndex == steps.count {
            SelectedSingleton.selected = [] //reset
            var x = done()
            print(x!)
            if x == nil {
                print("DONE IS NIL")
            }
            return x
        }
        return nil
    }
    
    func toDouble(_ arr: [String]) -> ([Double], Bool) {
        var doubleArr:[Double] = []
        for ele in arr {
            let doub:Double? = Double(ele.strip(chars: Constants.NON_NUMBER_INFORMATION))
            if doub != nil {
                doubleArr.append(doub!)
            } else {
                return ([], false)
            }
        }
        return (doubleArr, true)
    }
    
    func done() -> Graph? {
        print("WEDONE")
        switch self.graphType {
        case .bar:
            print("bar")
            let result = toDouble(self.data)
            if result.1 {
                print("BARMADE")
                print(self.title)
                print(self.xLabel)
                print(self.yLabel)
                print(self.xValues)
                print(result.0)
                let x = BarGraph(title: self.title, xAxisLabel: self.xLabel, yAxisLabel: self.yLabel, data: result.0, xAxisValues: self.xValues)
                if x == nil {
                    print("NO BAR GRAPH MADE")
                }
                self.finished = true
                return x
            } else {
                return nil
            }
        case .histogram:
            print("histogram")
        case .line:
            print("line")
            let result = toDouble(self.data)
            if result.1 {
                let x = LineGraph(title: self.title, xAxisLabel: self.xLabel, yAxisLabel: self.yLabel, data: result.0, xAxisValues: self.xValues)
                self.finished = true
                return x
            } else {
                return nil
            }
        case .multiLine:
            print("multiLine")
            let result = toDouble(self.data)
            if result.1 {
                let x = LineGraph(title: self.title, xAxisLabel: self.xLabel, yAxisLabel: self.yLabel, data: result.0, xAxisValues: self.xValues, keys: self.keys)
                self.finished = true
                return x
            } else {
                return nil
            }
        case .scatter:
            print("scatter")
        case .pie:
            print("pie")
        case .none:
            print("none")
        }
        self.finished = true
        return nil
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
    
    @State var step:String = "data"
    
    @Environment(\.colorScheme) var colorScheme
    @State var selectOrAdjust = true //true is select mode, false is adjust mode
    @State var graphFinished = false
    @State var graph:Graph!
    
    func makeGraph() -> some View {
        Group {
            switch gbViewModel.graphType {
            case .bar:
                //print("bar")
                let barGraph = graph as! BarGraph
                BarGraphView(ocrProperties: self.ocrProperties,
                             bars: barGraph.data,
                             barLabels: barGraph.xAxisValues,
                             yAxisLabel: barGraph.yAxisLabel,
                             xAxisLabel: barGraph.xAxisLabel)
                
            case .histogram:
                Text("some view")
            case .line:
                let lineGraph = graph as! LineGraph
                LineGraphView(ocrProperties: self.ocrProperties,
                              vals: lineGraph.data,
                              xLabels: lineGraph.xAxisValues,
                              yAxisLabel: lineGraph.yAxisLabel,
                              xAxisLabel: lineGraph.xAxisLabel)
                //Text("some view")
            case .multiLine:
                //Text("some view")
                let lineGraph = graph as! LineGraph
                LineGraphView(ocrProperties: self.ocrProperties,
                              vals: lineGraph.data,
                              xLabels: lineGraph.xAxisValues,
                              yAxisLabel: lineGraph.yAxisLabel,
                              xAxisLabel: lineGraph.xAxisLabel,
                              keys: lineGraph.keys)
            case .scatter:
                Text("some view")
            case .pie:
                Text("some view")
            case .none:
                Text("some view")
            }
        }
    }
    
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
                gbViewModel.submit(submitOrBack: false, selection: [])
                haptic()
                self.step = gbViewModel.currentStep
            }, label: {
                HStack {
                    Spacer()
                    Text("Back").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                }
            }).buttonStyle(GBVButtonStyle(backColor: .red)).padding([.leading])
            Button(action: {
                var graph:Graph? = gbViewModel.submit(submitOrBack: true, selection: SelectedSingleton.selected)
                if graph == nil {
                    print("WTF IS GOING ON")
                }
                if graph != nil && gbViewModel.finished {
                    print("🙃")
                    self.graph = graph!
                    self.graphFinished = true
                }
                haptic()
                self.step = gbViewModel.currentStep
            }, label: {
                HStack {
                    Spacer()
                    Text("Confirm Select").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                }
            }).buttonStyle(GBVButtonStyle(backColor: .green)).padding([.trailing])
        }
    }
    
    @State var editingCell = false
    //@State var cellContent = ""
    
    var body: some View {
        if !self.graphFinished {
            ZStack {
                Color(red: 44/255, green: 47/255, blue: 51/255, opacity: 1.0).edgesIgnoringSafeArea([.top, .bottom])
                VStack {
                    TableView(selectOrAdjust: $selectOrAdjust, editingCell: $editingCell)//, cellContent: $cellContent)
                    if !editingCell {
                    self.selectOrAdjustToggle()//.padding()
                    self.backConfirmButtons()//.padding()
                    }
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
//                if editingCell {
//                    HStack {
//                        Spacer()
//                        CustomTextField(text: $cellContent, isFirstResponder: true)
//                                    .frame(width: 300, height: 50)
//                                    .background(Color.red)
//                        Spacer()
//                    }
//                }
            }
        } else {
            ZStack {
                Color(red: 44/255, green: 47/255, blue: 51/255, opacity: 1.0).edgesIgnoringSafeArea([.top, .bottom])
                self.makeGraph()
            }
        }
    }
}

extension Color {
    static let lightBlue = Color(red: 0.678, green: 0.847, blue: 0.902)
    static let lightGrey = Color(red: 153/255, green: 170/255, blue: 181/255)
    //67.8% red, 84.7% green and 90.2% blue
}

func printTen<T>(arg: T) {
    for _ in 1 ... 10 {
        print(arg)
    }
}
