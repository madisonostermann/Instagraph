//
//  GraphEngine.swift
//  InstagraphEngine
//
//  Created by Lannie Hough on 5/15/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import Foundation

enum GraphType {
    case bar
    case histogram
    case line
    case pie
    case scatter
    case none
}

enum TablePart {
    case col
    case row
}

///arr: array to be operated on
///colOrRow: .col or .row to indicate if iterating across column or row
///pos: "position," which row or column to start on, defaults 0
///action: action to be applied to content of array
func twoDIterator<T>(_ arr: inout [[T]], _ colOrRow: TablePart, _ pos: Int = 0, action: (inout T) -> Void) {
    for x in 0 ..< (colOrRow == .col ? arr[pos].count : arr.count) {
        if colOrRow == .col {
            action(&arr[pos][x])
        } else {
            action(&arr[x][pos])
        }
    }
}

///Detects an arithmetic sequence
func detectArithmeticSequence<T: Numeric>(numbers: [T]) -> Bool {
    for i in 1 ..< numbers.count-1 {
        if numbers[i+1] - numbers[i] != numbers[i] - numbers[i-1] {
            return false
        }
    }
    return true
}

class GraphEngine {
    //properties represent raw tabular data and processed tabular data
    let rawTable:[[String]]
    var table:[[Cell]]
    //.0 represents number of columns that represent data, .1 represents number of rows that represent data
    lazy var dataColsDataRows:(Int, Int) = {
        for i in 0 ..< self.table.count { //across columns (right)
            for j in 0 ..< self.table[i].count { //across rows (down)
                if self.table[i][j].status == .data {
                    var cols:Int = 0
                    twoDIterator(&self.table, .col, i, action: { cell in
                        cols = cell.status == .data ? cols + 1 : cols
                    })
                    var rows:Int = 0
                    twoDIterator(&self.table, .row, i, action: { cell in
                        rows = cell.status == .data ? rows + 1 : rows
                    })
                    return (cols, rows)
                }
            }
        }
        return (0, 0)
    }()
    
    
    
    init(_ rawTable: [[String]]) {
        self.rawTable = rawTable
        self.table = GraphEngine.generateTable(rawTable: rawTable)
    }
    
    ///Input only n*n 2d arrays
    private static func generateTable(rawTable: [[String]]) -> [[Cell]] {
        var table:[[Cell]] = []
        
        for i in 0 ..< rawTable.count { //iterate across columns (iterate right)
            var col:[Cell] = []
            for j in 0 ..< rawTable[i].count { //iterate across rows (iterate down)
                let cell = Cell(row: j, col: i, cellContent: rawTable[i][j], tableContent: rawTable)
                col.append(cell)
            }
            table.append(col)
        }
        
        return table
    }
    
    func whichGraphTypes(table: [[Cell]]) -> GraphType {
        
        return .none
    }
    
//    func generateGraphs() -> [Graph] {
//        let graphs:[Graph] = []
//        return graphs
//    }
}

/*

j   0 | 1 | 2 | 3 i
0 | x
1 |
2 |     y       z
3 |

x: i = 0, j = 0
y: i = 1, j = 2
z: i = 3, j = 2

*/
