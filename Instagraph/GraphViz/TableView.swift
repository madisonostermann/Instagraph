//
//  TableView.swift
//  Instagraph
//
//  Created by Lannie Hough on 9/5/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

struct EditTableView: View {
    let table:[[String]] = [["Student Scores", "Student", "Maddie", "Dalton", "Aaron", "Rachel", "Kassie", "Cody"], ["Student Scores", "Score", "5", "1", "3", "9", "3", "7"]]
    var body: some View {
        VStack {
            
            Text("Print elements")
        }
    }
}

class TableModel {
    var tableModelFinished:Bool = false
    var tableCellPositions:[[CGPoint]] = []
}

struct TableView: View {
    
    let table:[[String]] = [["Student Scores", "Student", "Maddie", "Dalton", "Aaron", "Rachel", "Kassie", "Cody"], ["Student Scores", "Score", "5", "1", "3", "9", "3", "7"]]
    let tableModel:TableModel = TableModel()
    
    //@State var tableModelFinished:Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    let minWidth = Constants.SCREEN_WIDTH/5
    let minHeight = Constants.SCREEN_HEIGHT/20
    
    let maxWidth = Constants.SCREEN_WIDTH/2.5
    let maxHeight = Constants.SCREEN_HEIGHT/20
    
    struct ij: Hashable {
        let i:Int
        let j:Int
    }
    
    func fillSelectedSet(start: CGPoint, end: CGPoint) {
        var startij:ij
        var endij:ij
        
        var currentClosestij:ij = ij(i: 10000, j: 10000)
        var currentDifference:CGFloat = 99999999.9
        for i in 0 ..< self.tableModel.tableCellPositions.count {
            for j in 0 ..< self.tableModel.tableCellPositions[i].count {
                let xDifference = abs(self.tableModel.tableCellPositions[i][j].x-start.x)
                let yDifference = abs(self.tableModel.tableCellPositions[i][j].y-start.y)
                let totalDifference = xDifference + yDifference
                print(totalDifference)
                if totalDifference <= currentDifference {
                    print("Thing here")
                    currentDifference = totalDifference
                    currentClosestij = ij(i: i, j: j)
                }
            }
        }
        startij = currentClosestij
        currentClosestij = ij(i: 10000, j: 10000)
        currentDifference = 99999999.9
        for i in 0 ..< self.tableModel.tableCellPositions.count {
            for j in 0 ..< self.tableModel.tableCellPositions[i].count {
                let xDifference = abs(self.tableModel.tableCellPositions[i][j].x-end.x)
                let yDifference = abs(self.tableModel.tableCellPositions[i][j].y-end.y)
                let totalDifference = xDifference + yDifference
                if totalDifference <= currentDifference {
                    currentDifference = totalDifference
                    currentClosestij = ij(i: i, j: j)
                }
            }
        }
        endij = currentClosestij
        print("Start index:")
        print(String(startij.i) + String(startij.j))
        print("End index:")
        print(String(endij.i) + String(endij.j))
    }
    
    func findClosest() -> ij {
        return ij(i: 0, j: 0)
    }
    
    var highlightedAndSelectedSet:Set<ij> = [] //Set of cell locations which should be highlighted when dragger is used
        
    @State var dragCellStart:Int!
    @State var dragCellEnd:Int!
    
    func generateCell(i: Int, j: Int, w: CGFloat, h: CGFloat, initial: CGPoint) -> some View {
        
        let xPos:CGFloat = initial.x+(CGFloat(i)*w)
        let yPos:CGFloat = initial.y+(CGFloat(j)*self.minHeight)
        
        if !self.tableModel.tableModelFinished { //Make sure during subsequent view updates the model isn't changed - point coords should be generated once w/ initial view generation
            if j == 0 {
                self.tableModel.tableCellPositions.append([])
            }
            self.tableModel.tableCellPositions[i].append(CGPoint(x: xPos, y: yPos))
            if self.table.count == self.tableModel.tableCellPositions.count {
                if self.table[0].count == self.tableModel.tableCellPositions[self.table.count-1].count {
                    tableModel.tableModelFinished = true
                }
            }
        }
        
        return Text(self.table[i][j])
            .multilineTextAlignment(.leading)
            .frame(width: w, height: h)
            .background(Rectangle().stroke(self.colorScheme == .dark ? Color.white : Color.black))
            .position(
                x: xPos,
                y: yPos
            )
            .onTapGesture {
                print(String(i) + String(j))
                print(self.tableModel.tableCellPositions)
            }
    }
    
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
        
        //Where cell 0, 0 is centered - edge of cell 0, 0 will be half a cell width away from the left edge of the screen
        let initialPoint:CGPoint = CGPoint(x: (d.w*0.75), y: Constants.SCREEN_HEIGHT/8)
        
        return ZStack {
            ForEach(0 ..< self.table.count) { i in //For each column
                ForEach(0 ..< self.table[0].count) { j in //For each row
                    self.generateCell(i: i, j: j, w: d.w, h: d.h, initial: initialPoint)
                } //Inner ForEach end
            }
        } //ZStack end
    }
    
    @State var isDragging = false
    @State var dragStartPoint:CGPoint = CGPoint(x: 0, y: 0)
    @State var dragEndPoint:CGPoint = CGPoint(x: 0, y: 0)
    
    var body: some View {
        ZStack {
            self.generateCells().highPriorityGesture(
                DragGesture( minimumDistance: 1.0, coordinateSpace: .local)
                    .onEnded { value in
                        self.isDragging = false
                        self.dragEndPoint = value.location
                        self.fillSelectedSet(start: self.dragStartPoint, end: self.dragEndPoint)
                    }
                    .onChanged { value in
                        if !self.isDragging {
                            self.dragStartPoint = value.location
                        }
                        self.isDragging = true
                        self.dragEndPoint = value.location
                        //print(value.location)
                    }
            )
            if isDragging {
                Path { path in
                    path.move(to: self.dragStartPoint)
                    path.addLine(to: .init(x: self.dragEndPoint.x, y: self.dragEndPoint.y))
                }.stroke(Color.blue, lineWidth: CGFloat(3))
            }
        }
    } //var body end
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
                        //let frame = proxy.fr
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
