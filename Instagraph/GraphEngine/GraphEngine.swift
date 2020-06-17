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
    case multiLine
    case scatter
    case none
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
///Detects a date sequence

class GraphEngine {
    let rawTable:[[String]]
    var graphComponents:GraphComponents = GraphComponents()
    
    init(table: [[String]]) {
        self.rawTable = table
    }
    
    func determineGraphType() -> (Status, [Graph]) {
        var bestFit:GraphType = .none
        var status:Status = .failure
        var graphTypes:[GraphType] = []
        var graphs:[Graph] = []
        var dataStartCol:Int = 0; var dataStartRow:Int = 0; var reachedDataStartCol:Bool = false; var reachedDataStartRow:Bool = false
        var canBeTemporal:Bool = false //Temporal data should be able to be represented as a line graph
        var allColumnsData:Bool = false //If all columns contain data, can be a scatter plot

        //Iterate across columns and rows to extract information about location of data & other things
        acrossCols: for i in 0 ..< self.rawTable.count { //Across cols start
            downRows: for j in 0 ..< self.rawTable[i].count { //Down rows start
                
                ///Check if the first column is temporal descriptors rather than data if it contains numbers
                ///Block contains code to fully generate simple graph descriptions for 2xn tables based on the content of the first column and first couple rows
                ///Temporal 2xn tables can be represented as a line or bar graph, categorical tables can be represented as a bar graph,
                if (i == 0) && (GraphEngine.representableAs(content: self.rawTable[i][j]).0 == .number) {
                    print("Number in col 0")
                    //Check if numbers or other potential temporal types in first row (ADD OTHERS***)
                    var tempArr:[Double] = []
                    //for k in 0 ..< self.rawTable[i].count-j { //Populate an array with Double versions of numerical Strings in the column in question
                    for k in j ..< self.rawTable[i].count {
                        if GraphEngine.representableAs(content: self.rawTable[i][k]).0 == .number {
                            tempArr.append(Double(self.rawTable[i][k].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
                        }
                    }
                    print("=====", tempArr)
                    if detectArithmeticSequence(numbers: tempArr) { //Check if numbers in the column constitute a sequence
                        print("sequence detected")
                        canBeTemporal = true
                        if self.rawTable.count == 2 { //If only two columns, no more information necessary to construct a basic line and bar graph
                            graphTypes.append(.line)
                            let line:LineGraph = {
                                //Find what row the data starts in (if no data in 2nd column, return with .failure)
                                check: for v in 0 ..< self.rawTable[1].count {
                                    if GraphEngine.representableAs(content: self.rawTable[1][v]).0 == .number {
                                        reachedDataStartRow = true; dataStartRow = v; dataStartCol = 1; reachedDataStartCol = true; break check
                                    }
                                }
                                if !reachedDataStartRow || (j != dataStartRow) { //If no numerical data by the end of the column, no data exists at all and the table can probably not produce a valid graph.  Or if data row doesn't start at same place as temporal row there is a mismatch
                                    //print("failed here"); print(j); print(dataStartRow)
                                    status = .failure
                                    return LineGraph(title: "", xAxisLabel: "", yAxisLabel: "", data: [], xAxisValues: [])
                                }
                                var data:[Double] = []
                                for d in dataStartRow ..< self.rawTable[1].count { //Populate data field to build LineGraph
                                    data.append(Double(self.rawTable[1][d].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
                                }
                                print(data)
                                var xAxisVals:[String] = []
                                for x in j /* j is start of temporal data */ ..< self.rawTable[0].count { //Use temporal values as xAxisValues
                                    xAxisVals.append(self.rawTable[0][x])
                                }
                                let title:String = self.rawTable[0][0] == self.rawTable[1][0] ? self.rawTable[0][0] : ""
                                var xAxisLabel:String; var yAxisLabel:String
                                if self.rawTable[0][0] == self.rawTable[1][0] {
                                    xAxisLabel = self.rawTable[0][1]; yAxisLabel = self.rawTable[1][1] //First col should label temporal i.e. x-axis
                                } else {
                                    xAxisLabel = self.rawTable[0][0]; yAxisLabel = self.rawTable[1][0]
                                }
                                status = .success
                                return LineGraph(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisVals)
                            }(); if status == .failure {return (status, graphs)}
                            graphs.append(line)
                            //status = .success
                            return (status, graphs) //HERE add bar graph too, temporal can be represented as bar graph - don't return just keep going?
                        } else { //Represented temporally w/ more than two columns means many variable table
                            analyzeManyVariableTable() //TO DO THIS FUNCTION
                        }
                    } else {
                        //If non-sequential numbers are present in the column and we are in the first column we can conclude that data spans all columns, and we also know what row the data starts in.  We can infer by the fact that all rows contain data that the table can probably be well represented as a scatter plot.
                        /* dataStartCol already 0 */ reachedDataStartCol = true; dataStartRow = j; reachedDataStartRow = true; allColumnsData = true
                        if (self.rawTable.count == 2) && ({
                            dataStartRow == 1 || dataStartRow == 2 //In a scatter plot there should not be more than two descriptor rows (title & labels at most)
                        }()) && ({ //If all conditions true, we can definitely represent the table as a scatter plot
                            for l in 0 ..< 2 { //One of the descriptor rows should have two descriptors - one for each variable addressed by the plot
                                if self.rawTable[0][l] != self.rawTable[1][l] {
                                    return true
                                }
                            }
                            return false
                        }()) { //Open if statement
                            graphTypes.append(.scatter)
                            let scatter:ScatterPlot = { //Construct a scatter plot
                                var data:[[Double]] = [[], []]
                                for s in 0 ..< 2 {
                                    for p in dataStartRow ..< self.rawTable[s].count {
                                        data[s].append(Double(self.rawTable[s][p].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
                                    }
                                }
                                //If content of top two cells is the same, it should be an overall title for the graph
                                let title:String = self.rawTable[0][0] == self.rawTable[1][0] ? self.rawTable[0][0] : ""
                                var xAxisLabel:String; var yAxisLabel:String
                                if self.rawTable[0][0] == self.rawTable[1][0] {
                                    xAxisLabel = self.rawTable[0][1]; yAxisLabel = self.rawTable[1][1] //ARBITRARY as to which label is which, **maybe produce variations later
                                } else {
                                    xAxisLabel = self.rawTable[0][0]; yAxisLabel = self.rawTable[1][0]
                                }
                                return ScatterPlot(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data)
                            }() //End scatter construction
                            graphs.append(scatter)
                            status = .success
                            return (status, graphs) //Since a table like this won't realistically be representable by a bar or line graph we are done
                        } //End if statement
                        status = .failure //If non-temporal numbers are in the first row but the results can't be well represented as a scatter plot, it is a failure to graph the table
                        return (status, graphs)
                    }
                } else if (GraphEngine.representableAs(content: self.rawTable[i][j]).0 == .number) { //Check if cell is a number (data) in columns other than first - we know data is not temporal and therefore categorical (or nonsense) if no temporal data was found in first row
                    reachedDataStartRow = true; reachedDataStartCol = true; dataStartCol = i; dataStartRow = j
                    if self.rawTable.count != 2 { //Not simple table
                        analyzeManyVariableTable()
                    } else { //We know that the table has two columns and is categorical, we can produce a bar graph to represent it
                        graphTypes.append(.bar)
                        let bar:BarGraph = {
                            //Find what row the data starts in (if no data in 2nd column, return with .failure) - DONE
                            var data:[Double] = []
                            for d in dataStartRow ..< self.rawTable[1].count { //Populate data field to build LineGraph
                                data.append(Double(self.rawTable[1][d].strip(chars: Constants.NON_NUMBER_INFORMATION))!)
                            }
                            var xAxisVals:[String] = []
                            for x in dataStartRow /* Categorical descriptors should start at same row as data */ ..< self.rawTable[0].count { //Use categorical values as xAxisValues
                                xAxisVals.append(self.rawTable[0][x])
                            }
                            let title:String = self.rawTable[0][0] == self.rawTable[1][0] ? self.rawTable[0][0] : ""
                            var xAxisLabel:String; var yAxisLabel:String
                            if self.rawTable[0][0] == self.rawTable[1][0] {
                                xAxisLabel = self.rawTable[0][1]; yAxisLabel = self.rawTable[1][1] //First col should label temporal i.e. x-axis
                            } else {
                                xAxisLabel = self.rawTable[0][0]; yAxisLabel = self.rawTable[1][0]
                            }
                            //return LineGraph(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisVals)
                            return BarGraph(title: title, xAxisLabel: xAxisLabel, yAxisLabel: yAxisLabel, data: data, xAxisValues: xAxisVals)
                        }()
                        graphs.append(bar)
                        status = .success
                        return (status, graphs)
                    }
                    
                } //else continue looping
            } //Down rows loop end
        } //Across cols loop end
        if !reachedDataStartCol || !reachedDataStartRow { //if no data in table, can't make a graph
            status = .failure
        }
        return (status, graphs)
    }
    
    func analyzeManyVariableTable() {
        
    }
    
    func buildGraphComponents(graphType: GraphType, title: String = "",
                              xAxisLabel: String, yAxisLabel: String) -> Graph {
        var graph:Graph = Graph(title: "", xAxisLabel: "", yAxisLabel: "")
        switch graphType {
        case .scatter:
            print("Building graph for scatter plot.")
        case .bar:
            print("Building bar graph.")
        case .histogram:
            print("Building histogram.")
        case .line:
            print("Building line graph.")
        case .multiLine:
            print("Building graph for multi-line line graph.")
        case .none:
            print("Cannot build a graph with no specified type.")
        }
        return graph
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

class GraphComponents {
    var graphType:GraphType = .none
    var title:String!
    
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
