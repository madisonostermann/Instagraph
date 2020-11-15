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

func numIsPercent(theNumber: Double, isPercentOf: Double) -> Double {
    return 100.0 * (theNumber / isPercentOf)
}

///Detects an arithmetic sequence - maybe account for jumps in sequence with recursion
func detectArithmeticSequence<T: Numeric>(numbers: [T]) -> Bool {
    if numbers.count < 3 { //any two numbers is technically a sequence but irrelevant for this
        return false
    }
    //check if any same - not real seq: ex: 0, 0, 0, 0
    var temp:T? = nil
    for i in 0 ..< numbers.count {
        if temp == numbers[i] {
            return false
        }
        temp = numbers[i]
    }
    for i in 1 ..< numbers.count-1 { //[4, 5]
        if numbers[i+1] - numbers[i] != numbers[i] - numbers[i-1] {
            return false
        }
    }
    return true
}

func representableAsDate(str: String) -> Bool {
//    print(str)
    //print(Constants.ALL_MONTHS)
    //Attempt to match month names or month shorthand; Jan, January
    for month in Constants.ALL_MONTHS {
        if str.matchInsensitive(month) {
            //print(str)
            return true
        }
    }
    //Attempt to match dates; 12/02/2000, 02 / 12 / 2000, 5/5/05, 12-02-2000, 1/5
//    let splitSlashes = str.split("/")
//    if !(splitSlashes.count == 2 || splitSlashes.count == 3) {
//        var allNumeric = true
//        for item in splitSlashes {
////            if GraphEngine.representableAs(content: item).0 == RepresentableAs.number {
////
////            }
//        }
//    }
//    let splitDashes = str.split("-")
//    if !(splitDashes.count == 2 || splitDashes.count == 3) {
//
//    }
    
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
            //print("* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *")
            return buildSimpleGraphs(table: self.rawTable)
        } else {
            return buildComplexGraphs(table: self.rawTable)
        }
    }
    
    ///Called on larger more complex tables with greater than two variables
    func buildComplexGraphs(table: [[String]]) -> (Status, [Graph]) {
        return (.failure, [])
    }
    
    //Search for temporal indicator row/cols that have data (numbers) after (below/right) of them
    //Check for at least 75% data in adjacent row/col - not 100% because there could be OCR artefacts
    //return true indicates data is temporal - indicates line graph or not (indicates bar)
    func checkTemporalComplex(table: [[String]]) -> Bool {
        var reachedNumbers = false; var numbers:[Double] = []; var numStartRow = 0
        var reachedDateString = false; var dates:[String] = []; var dateStartRow = 0
        outer: for i in 0 ..< table.count { //go across cols
            for j in 0 ..< table[0].count { //check col (go across rows)
                //Check for raw numbers because an arithmetic sequence of percents or money is not really what we're looking for in temporal data
                if GraphEngine.representableAs(content: table[i][j]).0 == .number && GraphEngine.representableAs(content: table[i][j]).1 == .raw {
                    if !reachedNumbers {
                        reachedNumbers = true
                        numStartRow = j
                    }
                    numbers.append(Double(table[i][j].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
                }
                if representableAsDate(str: table[i][j]) {
                    if !reachedDateString {
                        reachedDateString = true
                        dateStartRow = j
                    }
                    dates.append(table[i][j])
                }
            }
            
            if reachedNumbers || reachedDateString {
                let percNum = numIsPercent(theNumber: Double(numbers.count),
                                           isPercentOf: Double(table[0].count - numStartRow))
                
                let percDate = numIsPercent(theNumber: Double(dates.count),
                                            isPercentOf: Double(table[0].count - dateStartRow))
                
                
                //check how much of the next col (next i) is data (numbers)
                var numData = 0.0
                for k in 0 ..< table[0].count {
                    if !(i+1 >= table.count) { //stop ioob error
                        if GraphEngine.representableAs(content: table[i+1][k]).0 == .number {
                            numData += 1
                        }
                    }
                }
                //check how much of prev col is data
                var numData2 = 0.0
                for k in 0 ..< table[0].count {
                    if i-1 >= 0 { //stop ioob error
                        if GraphEngine.representableAs(content: table[i-1][k]).0 == .number {
                            numData2 += 1
                        }
                    }
                }
                
                let percNextData = numIsPercent(theNumber: numData,
                                                isPercentOf: Double(table[0].count))
                let percPrevData = numIsPercent(theNumber: numData2,
                                                isPercentOf: Double(table[0].count))
                
                if percNextData > 50.0 { //if most of next col is data
                    if percDate > 75.0 { //and most of col in question is temporal dates
                        print("COL IS DATE SEQ")
                        return true
                    }
                    if percNum > 75.0 { //or most of col in question is numbers
                        if detectArithmeticSequence(numbers: numbers) { //and those numbers are temporal
//                            print("COL IS AR SEQ")
                            if !(percPrevData > 50.0) { //if previous row looks like data, arith sequence is just a coincidence and not indication of temporal data
                                print("COL IS AR SEQ")
                                return true
                            }
                        }
                    }
                }
                
            } //end -- if reachedNumbers || reachedDateString
            reachedNumbers = false; numbers = []; numStartRow = 0 //RESET
            reachedDateString = false; dates = []; dateStartRow = 0 //RESET
        } //out for loop end
        
        reachedNumbers = false; numbers = []; var numStartCol = 0 //reuse other vars but now going across cols (through a row)
        reachedDateString = false; dates = []; var dateStartCol = 0
        
        outer: for i in 0 ..< table[0].count { //go across rows
            for j in 0 ..< table.count { //check row (go across cols)
                if GraphEngine.representableAs(content: table[j][i]).0 == .number && GraphEngine.representableAs(content: table[j][i]).1 == .raw {
                    if !reachedNumbers {
                        reachedNumbers = true
                        numStartCol = j
                    }
                    numbers.append(Double(table[j][i].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
                }
                if representableAsDate(str: table[j][i]) {
                    //print("DATE IS: " + table[j][i])
                    if !reachedDateString {
                        reachedDateString = true
                        dateStartCol = j
                    }
                    dates.append(table[j][i])
                }
            }
            if reachedNumbers || reachedDateString {
                let percNum = numIsPercent(theNumber: Double(numbers.count),
                                           isPercentOf: Double(table.count - numStartCol))
                let percDate = numIsPercent(theNumber: Double(dates.count),
                                            isPercentOf: Double(table.count - dateStartCol))
                //check how much of the next col (next i) is data (numbers)
                var numData = 0.0
                for k in 0 ..< table.count {
                    if (i+1 < table[0].count) { //prevent ioob error
                        if GraphEngine.representableAs(content: table[k][i+1]).0 == .number {
                            numData += 1
                        }
                    }
                }
                var numData2 = 0.0
                for k in 0 ..< table.count {
                    if i-1 >= 0 { //prevent ioob error
                        if GraphEngine.representableAs(content: table[k][i-1]).0 == .number {
                            numData2 += 1
                        }
                    }
                }
                let percNextData = numIsPercent(theNumber: numData,
                                                isPercentOf: Double(table.count))
                let percPrevData = numIsPercent(theNumber: numData2,
                                                isPercentOf: Double(table.count))
                if percNextData > 50.0 { //if most of next row is data
                    if percDate > 75.0 { //and most of row in question is temporal dates
                        print("ROW IS DATE SEQ " + String(i))
                        return true
                    }
                    if percNum > 75.0 { //or most of col in question is numbers
                        if detectArithmeticSequence(numbers: numbers) { //and those numbers are temporal
//                            print("ROW IS AR SEQ" + String(i))
                            if !(percPrevData > 50.0) {
                                print("ROW IS AR SEQ" + String(i))
                                return true
                            }
                        }
                    }
                }
            } //end -- if reachedNumbers || reachedDateString {
            reachedNumbers = false; numbers = []; numStartCol = 0 //RESET
            reachedDateString = false; dates = []; dateStartCol = 0
        } //outer for loop end
        
        print("NO SEQ")
        return false
    }
    
    func recommendGraphs(table: [[String]]) -> GraphType {
        
        return .bar
    }
    
    ///Called on size 2xn tables to build appropriate graphs based mostly on the content of the first column
    ///Param: table - The table
    func buildSimpleGraphs(table: [[String]]) -> (Status, [Graph]) {
        //print("BUILDING SIMPLE GRAPH")
        var status:Status = .failure //At least one valid graph representation should be produced for this to be a success
        var graphs:[Graph] = []
        
        if table.count != 2 { return (.failure, []) }
        if table[0].count != table[1].count { return (.failure, []) }
        
        var reachedNumbers = false; var numberStartRow:Int = 0 //The row at which numbers start appearing in the table in col 0
        var reachedDateString = false; var dateStartRow:Int = 0
        var tempArr:[Double] = [] //Use to hold numbers in first column to test if they represent a sequence
        var dateTempArr:[String] = []
        for i in 0 ..< table[0].count {
            //print(table[0][i])
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
                //print("REP AS DATE")
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
                //print("=== Attempting to build line and bar graphs ===")
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
                //print("=== Attempting to build scatter plot ===")
                let scatter:(Status, ScatterPlot) = buildSimpleScatter(table: table, dataStartRow: numberStartRow)
                if scatter.0 == .success {
                    status = .success
                    graphs.append(scatter.1)
                }
            }
        } else if reachedDateString {
            //print("REACHED DATE STRING")
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
            //print("=== Attempting to build bar graph ===")
            check: for i in 0 ..< table[0].count {
                if GraphEngine.representableAs(content: table[1][i]).0 == .number {
                    let bar:(Status, BarGraph) = buildSimpleBar(table: table, categoryStartRow: i) //Use numbers as categories
                    if bar.0 == .success {
                        status = .success
                        graphs.append(bar.1)
                        //print("BUILD BAR GRAPH COMPLETE")
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
    
    
    static func reformatOCRArtefacts(arr: inout [[String]], checkIf: Set<Character>, shouldBe: Character) {
        //associate the row that data starts at with each column (if data is present, "data" identified by looking like number
        var dataStarts:Dictionary<Int, Int> = [:]
        for i in 0 ..< arr.count { //across cols
            downCol: for j in 0 ..< arr[0].count { //down cols
                if GraphEngine.representableAs(content: arr[i][j]).0 == .number {
                    let keyExists = dataStarts[i] != nil
                    if !keyExists {
                        dataStarts[i] = j
                        break downCol
                    }
                }
            }
        }
        //purge dictionary entries where most of the column isn't numbers - meaning probably isn't data
        for i in 0 ..< arr.count { //across cols
            var numNums = 0
            for j in 0 ..< arr[0].count { //down cols
                if GraphEngine.representableAs(content: arr[i][j]).0 == .number {
                    numNums += 1
                }
            }
            let mostOfColIsNums = numNums > arr[0].count / 2
            if !mostOfColIsNums {
                dataStarts.removeValue(forKey: i)
            }
        }
        
        //Find row position that data starts at most frequently (to see where data likely starts and ignore other kinds of numbers like identifiers)
        var rowStarts:Dictionary<Int, Int> = [:] //<row where data starts, number of times data starts on that row
        var firstColWithData = 999
        for (k, v) in dataStarts {
            let keyExists = rowStarts[v] != nil
            if keyExists {
                rowStarts[v]! += 1
            } else {
                rowStarts[v] = 1
            }
            if k < firstColWithData {
                firstColWithData = k
            }
        }
        
        var mostCommonStart = 0
        var mostCommonCount = 0
        for (k, v) in rowStarts {
            if v > mostCommonCount {
                mostCommonStart = k
                mostCommonCount = v
            }
        }
        //loop through data columns from start row to end, replace occurences of checkIf with ocurences of shouldBe
        for i in firstColWithData ..< arr.count {
            for j in mostCommonStart ..< arr[0].count {
                var k = 0
                for char in arr[i][j] {
                    if checkIf.contains(char) {
                        arr[i][j] = arr[i][j].replaceAt(k, with: shouldBe)
                    }
                    k += 1
                }
            }
        }
    }
    
    static func reformatEuropean(arr: inout [[String]]) {
        //Check if numbers are European formatted... ex: 300.000,50 is 300,000.50
        //Extract all data that can be formatted as a number to analyze
        var shouldReformat = false
        var checkFormat:[String] = []
        for i in 0 ..< arr.count {
            for j in 0 ..< arr[0].count {
                if representableAs(content: arr[i][j]).0 == .number {
                    checkFormat.append(arr[i][j])
                }
            }
        }
        var anyEuropeanNumbers = false
        var numEuropeanNumbers = 0
        outLoop: for check in checkFormat {
            //Check if there are any commas with anything save three numbers or three numbers followed by a decimal
            var reachedDecimal = false
            inLoop: for v in 0 ... check.count-1 {//check.count-1 ... 0 {
                let i = check.count-1-v //go from back
                switch i {
                case check.count-1:
                    if check.at(check.count-1) == "," {
                        anyEuropeanNumbers = true
                        numEuropeanNumbers += 1
                        continue outLoop
                    }
                case check.count-2:
                    if check.at(check.count-2) == "," {
                        anyEuropeanNumbers = true
                        numEuropeanNumbers += 1
                        continue outLoop
                    }
                case check.count-3:
                    if check.at(check.count-3) == "," {
                        anyEuropeanNumbers = true
                        numEuropeanNumbers += 1
                        continue outLoop
                    }
                default:
                    if reachedDecimal && check.at(i) == "." {
                        anyEuropeanNumbers = true
                        numEuropeanNumbers += 1
                    }
                    if check.at(i) == "." {
                        reachedDecimal = true
                    }
                    continue inLoop
                } //switch end

            } //inLoop end
        } //outLoop end
        
        if numIsPercent(theNumber: Double(numEuropeanNumbers),
                        isPercentOf: Double(checkFormat.count)) > 20.0 { //somewhat arbitrary % but otherwise it is likely an OCR issue of mistaking a . for a ,
            shouldReformat = true
        }
        if shouldReformat {
            //reformat
            for i in 0 ..< arr.count {
                for j in 0 ..< arr[0].count {
                    if representableAs(content: arr[i][j]).0 == .number {
                        var temp = arr[i][j]
                        //collect indices where , exist
                        var commaIndices:[Int] = []
                        //collect indices where . exist
                        var deciIndices:[Int] = []
                        for k in 0 ..< temp.count {
                            if temp.at(k) == "," {
                                commaIndices.append(k)
                            }
                            if temp.at(k) == "." {
                                deciIndices.append(k)
                            }
                        }
                        for index in commaIndices {
                            temp = temp.replaceAt(index, with: ".")
                        }
                        for index in deciIndices {
                            temp = temp.replaceAt(index, with: ",")
                        }
                        arr[i][j] = temp
                    }
                }
            }
        }
    }
    
    static func analyzeContent(arr: inout [[String]]) {
        
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
    
    func replaceAt(_ index: Int, with: Character) -> String {
        var newStr = ""
        for i in 0 ..< self.count {
            if i != index {
                newStr += String(self.at(i))
            } else {
                newStr += String(with)
            }
        }
        return newStr
    }
    
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

