//
//  TableView.swift
//  Instagraph
//
//  Created by Lannie Hough on 9/5/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import SwiftUI

//Used to store data about where cells are rendered in screen space & whether the initial render has completed
class TableModel {
    var tableModelFinished:Bool = false
    var tableCellPositions:[[CGPoint]] = []
}

struct TableView: View {
    
    @Binding var selectOrAdjust:Bool
    
    //let table:[[String]] = [["Student Scores", "Student", "Maddie", "Dalton", "Aaron", "Rachel", "Kassie", "Cody"], ["Student Scores", "Score", "5", "1", "3", "9", "3", "7"]]
    let table:[[String]] = [["Month", "Jan", "Feb", "March", "April", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"],
                            ["Temperature USA", "90.0", "83.2", "69.9", "50.1", "40.0", "35.3", "90.0", "83.2", "69.9", "50.1", "40.0", "35.3"],
                            ["Temperature China", "86.0", "83.2", "74.9", "65", "42.3", "40.0", "90.0", "83.2", "69.9", "50.1", "40.0", "35.3"],
                            ["Temperature Russia", "86.0", "83.2", "74.9", "65", "42.3", "40.0", "90.0", "83.2", "69.9", "50.1", "40.0", "35.3"],
                            ["Temperature England", "86.0", "83.2", "74.9", "65", "42.3", "40.0", "90.0", "83.2", "69.9", "50.1", "40.0", "35.3"],
                            ["Temperature Korea", "86.0", "83.2", "74.9", "65", "42.3", "40.0", "90.0", "83.2", "69.9", "50.1", "40.0", "35.3"]]
    let tableModel:TableModel = TableModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    let minWidth = Constants.SCREEN_WIDTH/5
    let minHeight = Constants.SCREEN_HEIGHT/20
    
    let maxWidth = Constants.SCREEN_WIDTH/2.5
    let maxHeight = Constants.SCREEN_HEIGHT/20
    
    struct ij: Hashable { //Represent indices in 2d array
        let i:Int
        let j:Int
    }
    
    @State var highlightedAndSelectedSet:Set<ij> = [] //Set of cell locations which should be highlighted when dragger is used
    
    //Function determines correct indices that give a bound to the cells selected by the user on the visible table view
    //Fills variable highlightedAndSelectedSet which is used for render information
    func fillSelectedSet(start: CGPoint, end: CGPoint) -> (ij, ij) {
        var startij:ij
        var endij:ij
        //print("Start: + \(String(Double(start.x))) \(String(Double(start.y)))")
        //print("End: + \(String(Double(end.x))) \(String(Double(end.y)))")
        
        var currentClosestijStart:ij = ij(i: 10000, j: 10000) //using impossibly large numbers to start
        var currentDifferenceStart:CGFloat = 99999999.9
        var currentClosestijEnd = ij(i: 10000, j: 10000)
        var currentDifferenceEnd:CGFloat = 99999999.9
        //Loop through all screen coordinate positions and compare them to start/end CGPoint positions made when user makes a selection on the visible table view
        //Finds correct cell by determining which index has screen coordinates that are closest to coordinates of start and end of dragging motion
        for i in 0 ..< self.tableModel.tableCellPositions.count {
            for j in 0 ..< self.tableModel.tableCellPositions[i].count {
                //start
                let xDifferenceStart = abs(self.tableModel.tableCellPositions[i][j].x-start.x)
                let yDifferenceStart = abs(self.tableModel.tableCellPositions[i][j].y-start.y)
                let totalDifferenceStart = xDifferenceStart + yDifferenceStart
                if totalDifferenceStart <= currentDifferenceStart {
                    currentDifferenceStart = totalDifferenceStart
                    currentClosestijStart = ij(i: i, j: j)
                }
                //end
                let xDifferenceEnd = abs(self.tableModel.tableCellPositions[i][j].x-end.x)
                let yDifferenceEnd = abs(self.tableModel.tableCellPositions[i][j].y-end.y)
                let totalDifferenceEnd = xDifferenceEnd + yDifferenceEnd
                if totalDifferenceEnd <= currentDifferenceEnd {
                    currentDifferenceEnd = totalDifferenceEnd
                    currentClosestijEnd = ij(i: i, j: j)
                }
            }
        }
        startij = currentClosestijStart
        endij = currentClosestijEnd
        
        let lowi:Int = min(startij.i, endij.i)
        let lowj:Int = min(startij.j, endij.j)
        let highi:Int = max(startij.i, endij.i)
        let highj:Int = max(startij.j, endij.j)
        
        for i in lowi ... highi {
            for j in lowj ... highj {
                let indices = ij(i: i, j: j)
                self.highlightedAndSelectedSet.insert(indices)
            }
        }

        //print("Start index:")
        //print(String(startij.i) + String(startij.j))
        //print("End index:")
        //print(String(endij.i) + String(endij.j))
        return (startij, endij)
    }
        
    @State var dragCellStart:Int!
    @State var dragCellEnd:Int!
    
    func getClosestCellToTap() -> ij {
        
        return ij(i: 0, j: 0)
    }
    
//    func mapOffsetToCellPositions(offset: CGSize) {
//        //print(tableModel.tableCellPositions)
//        for i in 0 ..< tableModel.tableCellPositions.count {
//            for j in 0 ..< tableModel.tableCellPositions[i].count {
//                tableModel.tableCellPositions[i][j] = CGPoint(
//                    x: tableModel.tableCellPositions[i][j].x + offset.width,
//                    y: tableModel.tableCellPositions[i][j].y + offset.height)
//            }
//        }
//        //print("===== ===== =====")
//        //print(tableModel.tableCellPositions)
//    }
    
    //Generates an individual cell at the correct screen location using indices of table, initial table start position (center of cell 1, 1), and cell dimensions
    func generateCell(i: Int, j: Int, w: CGFloat, h: CGFloat, initial: CGPoint) -> some View {
        
        let xPos:CGFloat = initial.x+(CGFloat(i)*w)
        let yPos:CGFloat = initial.y+(CGFloat(j)*self.minHeight)
        
        if !self.tableModel.tableModelFinished { //Make sure during subsequent view updates the model isn't changed - point coords should be generated once w/ initial view generation
            if j == 0 {
                self.tableModel.tableCellPositions.append([])
            }
            self.tableModel.tableCellPositions[i].append(CGPoint(
                x: xPos + offset.width,
                y: yPos + offset.height)) //offset included so when whole table position is adjusted these positions are generated properly
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
            ).foregroundColor(self.highlightedAndSelectedSet.contains(ij(i: i, j: j)) ? Color.blue : self.colorScheme == .dark ? Color.white : Color.black)
            .onTapGesture {
                print(String(i) + String(j))
                print(self.tableModel.tableCellPositions)
            }
    }
    
    func generateCells() -> some View {
        
        struct Dimensions { //Represented cell dimensions
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
        let initialPoint:CGPoint = CGPoint(x: (d.w*0.75), y: Constants.SCREEN_HEIGHT/16) // <-- MAKE DYNAMIC?  Seems to use local view coords already
        
        return ZStack {
            //Loops through table & creates cells as necessary
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
    
    
    
    //Used when panning in adjust mode or selecting cells with select mode & swipe gesture is bordering on edge of screen
    @State var currentOffset = CGSize(width: 0, height: 0)
    @State var offset = CGSize(width: 0, height: 0)
    
    func checkBeyondBordersWhileDragging() -> Bool {
        
        return false
    }
    
    var body: some View {
        ZStack {
            self.generateCells().offset(offset).highPriorityGesture(
                //
                DragGesture( minimumDistance: 1.0, coordinateSpace: .local)
                    .onEnded { value in
                        
                        if self.selectOrAdjust { //Drag to select mode
                            self.isDragging = false
                            self.dragEndPoint = value.location
                            self.highlightedAndSelectedSet = []
                            self.fillSelectedSet(start: self.dragStartPoint, end: self.dragEndPoint)
                        } else {
                            self.currentOffset = self.offset
                        }
                    }
                    .onChanged { value in
                        if self.selectOrAdjust {
                            
                            if !self.checkBeyondBordersWhileDragging() { //If not beyond borders that cause offset to change - happens as a result of dragging to edge of screen/table
                            
                                if !self.isDragging {
                                    self.dragStartPoint = value.location
                                }
                                self.isDragging = true
                                self.dragEndPoint = value.location
                            
                            } else {
                                
                            }
                            
                        } else {
                            let translationx = value.translation.width
                            let translationy = value.translation.height
                            self.offset = CGSize(
                                width: self.currentOffset.width + translationx,
                                height: self.currentOffset.height + translationy
                            )
                        }
                    }
            )
            //Visualizes drag motion as a line on screen from where the drag started to where the user's finger currently is
            if isDragging {
                Path { path in
                    path.move(to: self.dragStartPoint)
                    path.addLine(to: .init(x: self.dragEndPoint.x, y: self.dragEndPoint.y))
                }.stroke(Color.blue, lineWidth: CGFloat(3))
//                Circle()
//                    .foregroundColor(Color.blue)
//                    .position(x: self.dragStartPoint.x, y: self.dragStartPoint.y)
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