//
//  GraphBuilderView.swift
//  Instagraph
//
//  Created by Lannie Hough on 9/12/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

//EEnum exists in GraphEngine.swift

//enum GraphType {
//    case bar
//    case histogram
//    case line
//    case multiLine
//    case scatter
//    pie
//    case none
//}

struct GBVButton: ViewModifier {
    var bgColor:Color
    @Binding var isPressed:Bool
    func body(content: Content) -> some View {
        content
            .padding(30)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(bgColor)
                }
            )
            .scaleEffect(self.isPressed ? 0.8 : 1)
            .animation(.spring())
    }
    
}

extension View {
    func gbvButton(isPressed: Binding<Bool>, bgColor: Color) -> some View {
        self.modifier(GBVButton(bgColor: bgColor, isPressed: isPressed))
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
    
    var step:String = "Data"
    @State private var isPressed:Bool = false
    
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
                    Text("Confirm \(self.step)").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    Spacer()
                }
            }).buttonStyle(GBVButtonStyle(backColor: .green)).padding([.trailing])
//            Button("Back") {
//
//            }.padding().background(Color.red).foregroundColor(self.colorScheme == .dark ? Color.white : Color.black).cornerRadius(10)
//            Button("Confirm \(self.step)") {
//
//            }.padding().background(Color.green).foregroundColor(self.colorScheme == .dark ? Color.white : Color.black).cornerRadius(10)
        }
    }
    
    var body: some View {
        VStack {
            TableView(selectOrAdjust: $selectOrAdjust)
            self.selectOrAdjustToggle()//.padding()
            self.backConfirmButtons()//.padding()
        }
    }
}

extension Color {
    static let lightBlue = Color(red: 0.678, green: 0.847, blue: 0.902)
    //67.8% red, 84.7% green and 90.2% blue
}
