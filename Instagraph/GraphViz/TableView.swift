//
//  TableView.swift
//  Instagraph
//
//  Created by Lannie Hough on 9/5/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct Cell: View {
    @Environment(\.colorScheme) var colorScheme
    let w:CGFloat; let h:CGFloat; let str:String
    var body: some View {
        ZStack {
            Rectangle()
                .size(CGSize(width: w, height: h)).stroke(colorScheme == .dark ? Color.white : Color.black)
            Text(str)
        }
    }
}

struct TableView: View {
    
    let table:[[String]] = [["Student Scores", "Student", "Maddie", "Dalton", "Aaron", "Rachel", "Kassie", "Cody"], ["Student Scores", "Score", "5", "1", "3", "9", "3", "7"]]
    
    let width = Constants.SCREEN_WIDTH
    let height = Constants.SCREEN_HEIGHT
    
    @Environment(\.colorScheme) var colorScheme
    
    let minWidth = Constants.SCREEN_WIDTH/5
    let minHeight = Constants.SCREEN_HEIGHT/20
    
    func generateCell(point: CGPoint, str: String) -> some View {
        Cell(w: minWidth, h: minHeight, str: str)
//        ZStack {
//            Rectangle()
//                .size(CGSize(width: minWidth, height: minHeight)).stroke(Color.white)//colorScheme == .dark ? Color.white : Color.black)
//                //.offset(x: point.x, y: point.y)//.position(x: 200, y: 600)//point)
//            Text(str)//.position()
//        }//.position(x: 200, y: 200)//point.x, y: point.y)
    }
    
    @State var textSize: CGSize = .zero
    @State var textLocation: CGPoint = .zero
    
    let initialPoint:CGPoint = CGPoint(x: Constants.SCREEN_WIDTH/8, y: Constants.SCREEN_HEIGHT/8)
    
    func cells() -> some View {
        print(initialPoint.y)
        return ZStack {
        ForEach(0 ..< 3) { i in
            self.generateCell(
                point: CGPoint(
                    x: CGFloat(self.initialPoint.x+(CGFloat(i)*self.minWidth)),//200,//CGFloat(self.initialPoint.x+(CGFloat(i)*self.minWidth)),
                    y: self.initialPoint.y),//self.initialPoint.y),
                str: "banana").position(x: CGFloat(self.initialPoint.x+(CGFloat(i)*self.minWidth)), y: self.initialPoint.y)
        }
        }
    }
    
    var body: some View {
        //self.cells()
        //Cell(w: self.minWidth, h: self.minHeight, str: "banana")
        ZStack {
        ForEach(0 ..< 4) { i in
        Text("a long block of text")
            //.fixedSize(horizontal: true, vertical: true)
            .multilineTextAlignment(.leading)
            //.padding()
            .frame(width: self.minWidth, height: self.minHeight)
            .background(Rectangle().stroke(Color.white))
            .position(x: self.initialPoint.x+(CGFloat(i)*self.minWidth), y: self.initialPoint.y)
        }
        }
//        ZStack{
//            Rectangle()
//            .size(CGSize(width: minWidth, height: minHeight)).stroke(Color.white)//colorScheme == .dark ? Color.white : Color.black)
//                .position(x: 60, y: 100)//.offset(x: 40, y: 100)//x: point.x, y: point.y)
//            Text("Banana").position(x: 60, y: 100)
//            //Rectangle()
//            //.size(CGSize(width: minWidth, height: minHeight)).stroke(Color.red)//colorScheme == .dark ? Color.white : Color.black)
////                .offset(x: 60, y: 100)
//        }//.offset(x: 60, y: 100)
//        ForEach(0 ..< 3) { i in
//            self.generateCell(
//                point: CGPoint(
//                    x: CGFloat(self.initialPoint.x+(CGFloat(i)*self.minWidth)),//200,//CGFloat(self.initialPoint.x+(CGFloat(i)*self.minWidth)),
//                    y: self.initialPoint.y),//self.initialPoint.y),
//                str: "banana")
//        }
//        VStack {
//            ChildSizeReader(size: $textSize) {
//                Text("hi")
//            }
//            Text("Size is \(textSize.debugDescription)")
//        }
    }
}

struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                        //Color.clear.preference(key: SizePreferenceKey.self, value: proxy.position)
                    }
                )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

//struct Coordinate: Identifiable, Hashable {
//    var id: String {
//        "\(x)\(y)"
//    }
//
//    let x: CGFloat
//    let y: CGFloat
//}
//
//struct TestView: View {
//    let coordinates = [Coordinate(x: 10, y: 10), Coordinate(x: 100, y: 100)]
//
//    var body: some View {
//        ZStack {
//            ForEach(coordinates) { coordinate in
//                Circle()
//                    .size(width: 10, height: 10)
//                    .foregroundColor(Color.red)
//                    .offset(x: coordinate.x, y: coordinate.y)
//            }
//        }
//    }
//}
