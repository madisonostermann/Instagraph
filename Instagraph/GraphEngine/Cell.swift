//
//  Cell.swift
//  InstagraphEngine
//
//  Created by Lannie Hough on 5/15/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import Foundation

enum RepresentableAs {
    case string
    case number
    case empty
}

enum CellStatus {
    case data
    case descriptor
    case undefined
}

enum NumberDataType {
    case money
    case percent
    case raw
    case NaN
}

struct Constants {
    static let NON_NUMBER_INFORMATION:[Character] = ["$", "£", "€", "%", " "]
}

///Class represents and contains information about individual "cells" in a table, where a table is a 2d array
class Cell {
    let row:Int
    let col:Int
    
    let content:String
    let contentAsNumber:Double? //If the cell contains numerical information
    let cellRepresentableAs:(RepresentableAs, NumberDataType)
    
    let status:CellStatus
    
    //associations are in order of ascending priority
    var rowAssociations:[Association] = []
    var colAssociations:[Association] = []
    
    
    init(row: Int, col: Int, cellContent: String, tableContent: [[String]]) {
        self.row = row
        self.col = col
        self.content = cellContent
        self.cellRepresentableAs = Cell.representableAs(content: cellContent)
        
        let information = Cell.generateCellInformation(tableContent: tableContent, cellContent: self.content, cellRepresentableAs: self.cellRepresentableAs, row: row, col: col)
        
        self.status = information.0
        self.rowAssociations = information.1
        self.colAssociations = information.2
        
        if cellRepresentableAs.0 == .number {
            self.contentAsNumber = { (String) -> Double in
                let formattedContent:String = cellContent.strip(chars: Constants.NON_NUMBER_INFORMATION)
                let dbl:Double = Double(formattedContent)!
                return dbl
            }(cellContent)
        } else {
            self.contentAsNumber = nil
        }
    }
    
    private static func generateCellInformation(tableContent: [[String]], cellContent: String, cellRepresentableAs: (RepresentableAs, NumberDataType), row: Int, col: Int) -> (CellStatus, [Association], [Association]) {
        
        var cellStatus:CellStatus = .data //default to data
        var rowAssociations:[Association] = []
        var colAssociations:[Association] = []
        
        let rowLength = tableContent.count
        let colHeight = tableContent[0].count
        
        for i in 0 ..< rowLength { //check elements in same row
            if i == col { continue }
            let c:String = tableContent[i][row] //c is cell being checked against main cell
            if cellRepresentableAs == Cell.representableAs(content: c) { //if type is same (ex: number)
                if cellRepresentableAs.0 == .string {
                    cellStatus = .descriptor
                } else {
                    cellStatus = .data
                }
                //check if both data - nearby content analysis, if far left is probably descriptor, esp if top association is different
                    //determine which is data
                        //set cellStatus, add association
            } else {
                if cellRepresentableAs.0 == .string {
                    cellStatus = .descriptor
                } else {
                    cellStatus = .data
                }
                //determine which is data
                    //set cellStatus, add association
            }
            
        }
        
        for i in 0 ..< colHeight { //check elements in same column
            if i == row { continue }
            let c:String = tableContent[col][i]
            
        }
        
        return (cellStatus, rowAssociations, colAssociations)
    }
    
    private static func representableAs(content: String) -> (RepresentableAs, NumberDataType) {
        var representedAs:RepresentableAs
        var numberDataType:NumberDataType
        
        let moneySymbols:[Character] = ["$", "£", "€"]
        if content.contains(chars: moneySymbols) {
            numberDataType = .money
        } else if content.contains("%") {
            numberDataType = .percent
        } else {
            numberDataType = .raw
        }
        
        let formattedContent:String = content.strip(chars: Constants.NON_NUMBER_INFORMATION)
        
        if (Double(formattedContent) != nil) || (Int(formattedContent) != nil) {
            representedAs = .number
        } else if formattedContent == "" {
            representedAs = .empty
        } else {
            representedAs = .string
            numberDataType = .NaN
        }
        
        return (representedAs, numberDataType)
    }
    
}

enum AssociationClass {
    case single //if descriptor is associated with single line of data
    case multiple //if descriptor is associated with multiple lines of data
}

class Association {
    
}

extension String {
    
    func strip(char: Character) -> String {
        var newStr:String = ""
        for c in self {
            if c != char {
                newStr += String(c)
            }
        }
        return newStr
    }
    
    func strip(chars: [Character]) -> String {
        var newStr:String = ""
        for c in self {
            if !chars.contains(c) {
                newStr += String(c)
            }
        }
        return newStr
    }
    
    func contains(chars: [Character]) -> Bool {
        for c in chars {
            if self.contains(c) {
                return true
            }
        }
        return false
    }
    
}
