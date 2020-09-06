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
    
    @Environment(\.colorScheme) var colorScheme
    
    let minWidth = Constants.SCREEN_WIDTH/5
    let minHeight = Constants.SCREEN_HEIGHT/20
    
    let maxWidth = Constants.SCREEN_WIDTH/2.5
    let maxHeight = Constants.SCREEN_HEIGHT/20
    
    struct ij: Hashable {
        let i:Int
        let j:Int
    }
    
    var highlightedSet:Set<ij> = [] //Set of cell locations which should be highlighted when dragger is used
    
    //let initialPoint:CGPoint = CGPoint(x: Constants.SCREEN_WIDTH/8, y: Constants.SCREEN_HEIGHT/8)
    
    func generateCells() -> some View {
        
        struct Dimensions {
            var h: CGFloat
            var w: CGFloat
        }
        
        var d:Dimensions = Dimensions(h: self.minHeight, w: 0.0) //2.5, 4, 5
        
        //Select width of cells - cells have a minimum width and if there are enough columns (or rows), the table will stretch offscreen
        if table.count <= 2 {
            d.w = Constants.SCREEN_WIDTH/2.5
        } else if table.count == 3 {
            d.w = Constants.SCREEN_WIDTH/3.5
        } else {
            d.w = self.minWidth
        }
        
        let initialPoint:CGPoint = CGPoint(x: (d.w*0.75), y: Constants.SCREEN_HEIGHT/8)
        
        return ZStack {
            ForEach(0 ..< self.table.count) { i in
                ForEach(0 ..< self.table[0].count) { j in
                    Text(self.table[i][j])
                    .multilineTextAlignment(.leading)
                        .frame(width: d.w, height: d.h)
                    .background(Rectangle().stroke(Color.white))
                    .position(
                        x: initialPoint.x+(CGFloat(i)*d.w),//self.minWidth),
                        y: initialPoint.y+(CGFloat(j)*self.minHeight)
                    )
                        .onTapGesture {
                            print(String(i) + String(j))
                    }
                    //.pop
                } //Inner ForEach end
            }
        } //ZStack end
    }
    
    var body: some View {
        VStack {
        self.generateCells()
        Spacer()
            Text("Press me")
            Spacer()
            Text("Press me too")
        }
    }
}

// ========== ========== ========== ========== ========== //

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
