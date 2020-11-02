//
//  GraphEngine.swift
//  InstagraphEngine
//
//  Created by Lannie Hough on 5/15/20.
//  Copyright © 2020 Lannie Hough. All rights reserved.
//

import Foundation

enum GraphType: String {
    case bar = "bar"
    case histogram = "histogram"//using as multi-bar
    case line = "line"
    case multiLine = "multiLine"
    case scatter = "scatter"
    case pie = "pie"
    case none = ""
}

enum TablePart {
    case col
    case row
}

///Indicates whether the graphing engine found a suitable way to graph the data
enum Status {
    case success
    case failure
}

//When checking temporal data, check months & various time formats
enum months {
    
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

///Detects an arithmetic sequence - maybe account for jumps in sequence with recursion
func detectArithmeticSequence<T: Numeric>(numbers: [T]) -> Bool {
    for i in 1 ..< numbers.count-1 {
        if numbers[i+1] - numbers[i] != numbers[i] - numbers[i-1] {
            return false
        }
    }
    return true
}

func representableAsDate(str: String) -> Bool {
    print(Constants.ALL_MONTHS)
    //Attempt to match month names or month shorthand; Jan, January
    for month in Constants.ALL_MONTHS {
        if str.matchInsensitive(month) {
            return true
        }
    }
    //Attempt to match dates; 12/02/2000, 02 / 12 / 2000, 5/5/05, 12-02-2000, 1/5
    let splitSlashes = str.split("/")
    if !(splitSlashes.count == 2 || splitSlashes.count == 3) {
        var allNumeric = true
        for item in splitSlashes {
//            if GraphEngine.representableAs(content: item).0 == RepresentableAs.number {
//
//            }
        }
    }
    let splitDashes = str.split("-")
    if !(splitDashes.count == 2 || splitDashes.count == 3) {
        
    }
    
    return false
}

func dateToInt(_ str: String) -> Int {
    for month in 0 ..< Constants.ALL_MONTHS.count {
        if str == Constants.ALL_MONTHS[month] {
            return month % 12
        }
    }
    
    return 0
}

///Detects a date sequence
func detectDateSequence(strings: [String]) -> Bool {
    for i in 1 ..< strings.count-1 {
        if dateToInt(strings[i+1]) - dateToInt(strings[i]) != dateToInt(strings[i]) - dateToInt(strings[i-1]) {
            return false
        }
    }
    return true
}


//Suggestions - one table in picture
class GraphEngine {
    let rawTable:[[String]]
    //var graphComponents:GraphComponents = GraphComponents()
    
    init(table: [[String]]) {
        self.rawTable = table
    }
    
    func determineGraphType() -> (Status, [Graph]) {
        if self.rawTable.count == 2 {
            print("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *")
            return buildSimpleGraphs(table: self.rawTable)
        } else {
            return buildComplexGraphs(table: self.rawTable)
        }
    }
    
    ///Called on larger more complex tables with greater than two variables
    func buildComplexGraphs(table: [[String]]) -> (Status, [Graph]) {
        return (.failure, [])
    }
    
    ///Called on size 2xn tables to build appropriate graphs based mostly on the content of the first column
    ///Param: table - The table
    func buildSimpleGraphs(table: [[String]]) -> (Status, [Graph]) {
        print("BUILDING SIMPLE GRAPH")
        var status:Status = .failure //At least one valid graph representation should be produced for this to be a success
        var graphs:[Graph] = []
        
        if table.count != 2 { return (.failure, []) }
        if table[0].count != table[1].count { return (.failure, []) }
        
        var reachedNumbers = false; var numberStartRow:Int = 0 //The row at which numbers start appearing in the table in col 0
        var reachedDateString = false; var dateStartRow:Int = 0
        var tempArr:[Double] = [] //Use to hold numbers in first column to test if they represent a sequence
        var dateTempArr:[String] = []
        for i in 0 ..< table[0].count {
            print(table[0][i])
            if GraphEngine.representableAs(content: table[0][i]).0 == .number {
                if !reachedNumbers {
                    numberStartRow = i
                    reachedNumbers = true
                }
                tempArr.append(Double(table[0][i].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
            }
//            if reachedNumbers {
//                tempArr.append(Double(table[0][i].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
//            }
            if representableAsDate(str: table[0][i]) {
                print("REP AS DATE")
                if !reachedDateString {
                    dateStartRow = i
                    reachedDateString = true
                }
                dateTempArr.append(table[0][i])
            }
        }
        
        //If the first column has numbers, the data could be either temporal (with the numbers representing x-axis values) and therefore representable as a simple line graph or bar graph, or the numbers could represent data points in which case a scatter plot makes the most sense (comparing two variables, one in each column).  If it does not have numbers, the table is possibly categorical and could be represented as a bar graph or pie chart (?)
        if reachedNumbers {
            if detectArithmeticSequence(numbers: tempArr) { //Try to build line and bar graphs
                print("=== Attempting to build line and bar graphs ===")
                let line:(Status, LineGraph) = buildSimpleLine(table: table, temporalStartRow: numberStartRow)
                if line.0 == .success {
                    status = .success
                    graphs.append(line.1)
                }
                let bar:(Status, BarGraph) = buildSimpleBar(table: table, categoryStartRow: numberStartRow) //Use numbers as categories
                if bar.0 == .success {
                    status = .success
                    graphs.append(bar.1)
                }
            } else { //Try to build scatter plot
                print("=== Attempting to build scatter plot ===")
                let scatter:(Status, ScatterPlot) = buildSimpleScatter(table: table, dataStartRow: numberStartRow)
                if scatter.0 == .success {
                    status = .success
                    graphs.append(scatter.1)
                }
            }
        } else if reachedDateString {
            print("REACHED DATE STRING")
            if detectDateSequence(strings: dateTempArr) {
                let line:(Status, LineGraph) = buildSimpleLine(table: table, temporalStartRow: dateStartRow)
                if line.0 == .success {
                    status = .success
                    graphs.append(line.1)
                }
                let bar:(Status, BarGraph) = buildSimpleBar(table: table, categoryStartRow: dateStartRow) //Use numbers as categories
                if bar.0 == .success {
                    status = .success
                    graphs.append(bar.1)
                }
            }
        } else { //Only a bar graph can still make sense for the table if no numbers are in the first column
            //Find first row with data in 2nd column and assume it is where the categories start
            print("=== Attempting to build bar graph ===")
            check: for i in 0 ..< table[0].count {
                if GraphEngine.representableAs(content: table[1][i]).0 == .number {
                    let bar:(Status, BarGraph) = buildSimpleBar(table: table, categoryStartRow: i) //Use numbers as categories
                    if bar.0 == .success {
                        status = .success
                        graphs.append(bar.1)
                    }
                    break check
                }
            }
        }
        
        return (status, graphs)
    }
    
    ///Function attempts to build a simple scatter plot for a 2xn table
    ///Param: table - The table to convert into a graph representation
    ///Param: dataStartRow - The row in which the data starts in col 0
    func buildSimpleScatter(table: [[String]], dataStartRow: Int) -> (Status, ScatterPlot) {
        var data:[[Double]] = [[], []]; var title:String = ""; var xAxisLabel:String = ""; var yAxisLabel:String = ""
        //Make sure data starts in the same row in both columns
        var reachedData = false; var dataStartRowColTwo = 0
        for i in 0 ..< table[1].count {
            if GraphEngine.representableAs(content: table[1][i]).0 == .number {
                if !reachedData {
                    dataStartRowColTwo = i
                    reachedData = true
                    if dataStartRow != dataStartRowColTwo { //Probably not a valid graph representation
                        return (.failure, ScatterPlot(title: "", xAxisLabel: "", yAxisLabel: "", data: data))
                    }
                }
                data[0].append(Double(table[0][i].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
                data[1].append(Double(table[0][i].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
            } else if reachedData { //If non-number content (not data) exists below data, the table probably cannot be represented as a valid graph
                return (.failure, ScatterPlot(title: "", xAxisLabel: "", yAxisLabel: "", data: data))
            }
        }
        //xAxisLabel should be directly above the category indicators and yAxisLabel should be directly above the data.  A descriptor spanning both rows is probably a title
        switch dataStartRow {
        case 0: //No title or labels given within the table
            return (.success, ScatterPlot(title: "My Graph", xAxisLabel: "", yAxisLabel: "", data: data))
        case 1: //Top row contains either title or axis labels
            if table[0][0] == table[1][0] {
                title = table[0][0]
                return (.success, ScatterPlot(title: title, xAxisLabel: "", yAxisLabel: "", data: data))
            } else {
                xAxisLabel = table[0][0]; yAxisLabel = table[1][0]
                return (.success, ScatterPlot(title: "", xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data))
            }
        case 2: //Top row contains title or useless information, rows above data contain labels or useless information
            title = table[0][0] == table[1][0] ? table[0][0] : "My Graph"
            if table[0][1] != table[1][1] {
                xAxisLabel = table[0][1]; yAxisLabel = table[1][1]
            }
            return (.success, ScatterPlot(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data))
        default: //Try to get labels from the row above the data, discard rest of information
            if table[0][dataStartRow-1] != table[1][dataStartRow-1] {
                xAxisLabel = table[0][dataStartRow-1]; yAxisLabel = table[1][dataStartRow-1]
                return (.success, ScatterPlot(title: "My Graph", xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data))
            } else { return (.success, ScatterPlot(title: "My Graph", xAxisLabel: "", yAxisLabel: "", data: data)) }
        }
    }
    
    // NOTE: The logic for building simple bar and line graph components is essentially identical and the methods could be merged but I'm leaving them separate for simplicity in calling and returning
    ///Function attempts to build a simple bar graph for a 2xn table
    ///Param: table - The table to convert into a graph representation
    ///Param: categoryStartRow - The row in which the categorical descriptors starts
    func buildSimpleBar(table: [[String]], categoryStartRow: Int) -> (Status, BarGraph) {
        //Graph components
        var title:String = ""; var xAxisLabel:String = ""; var yAxisLabel:String = ""; var data:[Double] = []; var xAxisValues:[String] = []
        //Check where data starts in second column
        var reachedData = false; var dataStartRow = 0
        
        for i in 0 ..< table[1].count {
            if GraphEngine.representableAs(content: table[1][i]).0 == .number {
                if !reachedData {
                    dataStartRow = i
                    reachedData = true
                    if categoryStartRow != dataStartRow { //Probably not a valid graph representation
                        return (.failure, BarGraph(title: "", xAxisLabel: "", yAxisLabel: "", data: [], xAxisValues: []))
                    }
                }
                data.append(Double(table[1][i].strip(chars: Constants.NON_NUMBER_INFORMATION))!) //Construct data with numbers from second col
                xAxisValues.append(table[0][i]) //Construct corresponding x-axis values
            } else if reachedData { //If non-number content (not data) exists below data, the table probably cannot be represented as a valid graph
                return (.failure, BarGraph(title: "", xAxisLabel: "", yAxisLabel: "", data: [], xAxisValues: []))
            }
        }
        //xAxisLabel should be directly above the category indicators and yAxisLabel should be directly above the data.  A descriptor spanning both rows is probably a title
        switch categoryStartRow {
        case 0: //No title or labels given within the table
            return (.success, BarGraph(title: "My Graph", xAxisLabel: "", yAxisLabel: "", data: data, xAxisValues: xAxisValues))
        case 1: //Top row contains either title or axis labels
            if table[0][0] == table[1][0] {
                title = table[0][0]
                return (.success, BarGraph(title: title, xAxisLabel: "", yAxisLabel: "", data: data, xAxisValues: xAxisValues))
            } else {
                xAxisLabel = table[0][0]; yAxisLabel = table[1][0]
                return (.success, BarGraph(title: "", xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisValues))
            }
        case 2: //Top row contains title or useless information, rows above data contain labels or useless information
            title = table[0][0] == table[1][0] ? table[0][0] : "My Graph"
            if table[0][1] != table[1][1] {
                xAxisLabel = table[0][1]; yAxisLabel = table[1][1]
            }
            return (.success, BarGraph(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisValues))
        default: //Try to get labels from the row above the data, discard rest of information
            if table[0][categoryStartRow-1] != table[1][categoryStartRow-1] {
                xAxisLabel = table[0][categoryStartRow-1]; yAxisLabel = table[1][categoryStartRow-1]
                return (.success, BarGraph(title: "My Graph", xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisValues))
            } else { return (.success, BarGraph(title: "My Graph", xAxisLabel: "", yAxisLabel: "", data: data, xAxisValues: xAxisValues)) }
        }
    }
    
    ///Function attempts to build a simple line graph for a 2xn table
    ///Param: table - The table to convert into a graph representation
    ///Param: temporalStartRow - The row in which the temporal descriptors starts
    func buildSimpleLine(table: [[String]], temporalStartRow: Int) -> (Status, LineGraph) {
        //Graph components
        var title:String = ""; var xAxisLabel:String = ""; var yAxisLabel:String = ""; var data:[Double] = []; var xAxisValues:[String] = []
        //Check where data starts in second column
        var reachedData = false; var dataStartRow = 0
        
        for i in 0 ..< table[1].count {
            if GraphEngine.representableAs(content: table[1][i]).0 == .number {
                if !reachedData {
                    dataStartRow = i
                    reachedData = true
                    if temporalStartRow != dataStartRow { //Probably not a valid graph representation
                        return (.failure, LineGraph(title: "", xAxisLabel: "", yAxisLabel: "", data: [], xAxisValues: []))
                    }
                }
                data.append(Double(table[1][i].strip(chars: Constants.NON_NUMBER_INFORMATION))!) //Construct data with numbers from second col
                xAxisValues.append(table[0][i]) //Construct corresponding x-axis values
            } else if reachedData { //If non-number content (not data) exists below data, the table probably cannot be represented as a valid graph
                return (.failure, LineGraph(title: "", xAxisLabel: "", yAxisLabel: "", data: [], xAxisValues: []))
            }
        }
        //xAxisLabel should be directly above the temporal indicators and yAxisLabel should be directly above the data.  A descriptor spanning both rows is probably a title
        switch temporalStartRow {
        case 0: //No title or labels given within the table
            return (.success, LineGraph(title: "My Graph", xAxisLabel: "", yAxisLabel: "", data: data, xAxisValues: xAxisValues))
        case 1: //Top row contains either title or axis labels
            if table[0][0] == table[1][0] {
                title = table[0][0]
                return (.success, LineGraph(title: title, xAxisLabel: "", yAxisLabel: "", data: data, xAxisValues: xAxisValues))
            } else {
                xAxisLabel = table[0][0]; yAxisLabel = table[1][0]
                return (.success, LineGraph(title: "", xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisValues))
            }
        case 2: //Top row contains title or useless information, rows above data contain labels or useless information
            title = table[0][0] == table[1][0] ? table[0][0] : "My Graph"
            if table[0][1] != table[1][1] {
                xAxisLabel = table[0][1]; yAxisLabel = table[1][1]
            }
            return (.success, LineGraph(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisValues))
        default: //Try to get labels from the row above the data, discard rest of information
            if table[0][temporalStartRow-1] != table[1][temporalStartRow-1] {
                xAxisLabel = table[0][temporalStartRow-1]; yAxisLabel = table[1][temporalStartRow-1]
                return (.success, LineGraph(title: "My Graph", xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisValues))
            } else { return (.success, LineGraph(title: "My Graph", xAxisLabel: "", yAxisLabel: "", data: data, xAxisValues: xAxisValues)) }
        }
    }
    
    //Checks if a string can be represented as a number and if so, what kind of number
    static func representableAs(content: String) -> (RepresentableAs, NumberDataType) {
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

enum RepresentableAs {
    case string
    case number
    case empty
}

enum NumberDataType {
    case money
    case percent
    case raw
    case NaN
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
    
    func split(_ char: Character) -> [[String]] {
        var split:[[String]] = []
        split.append([])
        var arrCount:Int = 0
        var i:Int = 0
        for c in self {
            if char != c {
                split[arrCount].append(String(c))
            } else {
                arrCount += 1
            }
            i += 1
        }
        return split
    }
    
    ///Spits string into two at a given position - character at position is part of second string in the split
    func split(_ pos: Int) -> (String, String) {
        var split:[[String]] = [[], []]
        var i:Int = 0
        for c in self {
            if i < pos {
                split[0].append(String(c))
            }
            if i >= pos {
                split[1].append(String(c))
            }
            i += 1
        }
        var partOne:String = ""
        var partTwo:String = ""
        for (c, ch) in zip(split[0], split[1]) {
            partOne += String(c)
            partTwo += String(ch)
        }
        return (partOne, partTwo)
    }
    
    func at(_ pos: Int) -> Character {
        var i:Int = 0
        for c in self {
            if i == pos {
                return c
            }
            i += 1
        }
        return "a"
    }
    
    func matchInsensitive(_ str: String) -> Bool {
        if self.uppercased() != str.uppercased() {
            return false
        }
        return true
    }
    
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

