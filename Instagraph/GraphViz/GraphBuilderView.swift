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

struct GraphBuilderView: View {
    
    var step:String = "Data"
    
    @Environment(\.colorScheme) var colorScheme
    @State var selectOrAdjust = true //true is select mode, false is adjust mode
    
    func selectOrAdjustToggle() -> some View {
        HStack {
            Button("Select") {
                self.selectOrAdjust.toggle()
            }.padding().background(self.selectOrAdjust ? Color.blue : Color.lightBlue).foregroundColor(self.colorScheme == .dark ? Color.white : Color.black).cornerRadius(10)
            Button("Adjust") {
                self.selectOrAdjust.toggle()
            }.padding().background(!self.selectOrAdjust ? Color.blue : Color.lightBlue).foregroundColor(self.colorScheme == .dark ? Color.white : Color.black).cornerRadius(10)
        }
    }
    
    func backConfirmButtons() -> some View {
        HStack {
            Button("Back") {
                
            }.padding().background(Color.red).foregroundColor(self.colorScheme == .dark ? Color.white : Color.black).cornerRadius(10)
            Button("Confirm \(self.step)") {
                
            }.padding().background(Color.green).foregroundColor(self.colorScheme == .dark ? Color.white : Color.black).cornerRadius(10)
        }
    }
    
    var body: some View {
        VStack {
            TableView(selectOrAdjust: $selectOrAdjust)
            self.selectOrAdjustToggle().padding()
            self.backConfirmButtons().padding()
        }
    }
}

extension Color {
    static let lightBlue = Color(red: 0.678, green: 0.847, blue: 0.902)
    //67.8% red, 84.7% green and 90.2% blue
}
