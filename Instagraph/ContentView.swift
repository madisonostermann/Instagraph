//
//  ContentView.swift
//  Instagraph
//
//  Created by Madison Gipson on 5/25/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var getImage: Bool = false
    @State private var source = ""
    @State private var image: Image? = nil
    @State private var finalImage: Image? = nil
    @State private var text: String = ""
    
    @State private var actionSheet: Bool = false
    @State private var showText: Bool = true //if false, show image
    @State private var screenSize = UIScreen.main.bounds
    
    
    var body: some View {
        VStack {
            if image != nil && text != "" {
                VStack {
                    if showText {
                        ScrollView {Text(text)}
                    } else {
                        finalImage?.resizable().padding([.vertical, .horizontal])
                    }
                    Spacer()
                    HStack {
                        Button(showText ? "Show Image" : "Show Text") {
                            self.showText.toggle()
                        }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
                        Button("Choose New Image") {
                            self.getImage = false
                            self.source = ""
                            self.image = nil
                        }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
                    }
                }.padding([.vertical, .horizontal])
            } else {
                Button("Import Image") {
                    self.actionSheet = true
                }.actionSheet(isPresented: $actionSheet) {
                    ActionSheet(title: Text("Select Image Source"), buttons: [
                        .default(Text("Photo Library")) {
                            self.getImage = true
                            self.source = "Photo"
                        },
                        .default(Text("Documents")) {
                            self.getImage = true
                            self.source = "Document"
                        },
                        .default(Text("Take Photo")) {
                            self.getImage = true
                            self.source = "Camera"
                        },
                        .cancel()
                    ])
                }.padding().background(Color.gray).foregroundColor(Color.white).cornerRadius(10)
            }
        }.sheet(isPresented: self.$getImage) {
            GetImage(isShown: self.$getImage, source: self.$source, image: self.$image, finalImage: self.$finalImage, text: self.$text)
        }
    }
}
