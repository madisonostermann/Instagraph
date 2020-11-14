//
//  ExtraTestTables.swift
//  Instagraph
//
//  Created by Lannie Hough on 11/5/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation

class TestTables {
    static func testTables() {
        var i = 0
        for table in not2ColTables {
            var t = table
            let recommendStart = DispatchTime.now()
            GraphEngine.reformatEuropean(arr: &t)
            //print(t)
            let g = GraphEngine(table: t)
            let result = g.checkTemporalComplex(table: g.rawTable)
            let recommendEnd = DispatchTime.now()
            let time = recommendEnd.uptimeNanoseconds - recommendStart.uptimeNanoseconds
            print(String(i) + ": " + String(result) + " // time: " + String(Double(time)/1000000))
            i += 1
        }
        print(Constants.ALL_MONTHS)
    }
    
    static func test2Tables() {
        var i = 0
        twoColTables = reformatArr(arr: twoColTables)
        for table in twoColTables {
            var t = table
            let g = GraphEngine(table: t)
            let recommendStart = DispatchTime.now()
            let result = g.determineGraphType()
            let recommendEnd = DispatchTime.now()
            let time = recommendEnd.uptimeNanoseconds - recommendStart.uptimeNanoseconds
            for x in result.1 {
                print(String(i) + ": ", x, " // time: " + String(Double(time)/1000000))
            }
            i += 1
        }
    }

}

var not2ColTables:[[[String]]] = [
    [   //Good example once ï is sorted out and European commas are accounted for
        ["Method", "Naïve Bayes", "C45", "GOV", "DOG", "RF_CT"],
        ["Classification Accuracy (%)", "58,3", "69,8", "71,2", "71,4", "87,7"],
        ["Standard Deviation", "1,5", "4,7", "2,9", "2,6", "0,6"]
    ], //0 - mbar
    [
        ["City", "London", "Paris", "Tokyo", "Washington DC", "Kyoto", "Los Angeles"],
        ["Date opened", "1863", "1900", "1927", "1976", "1981", "2001"],
        ["Kilometres of route", "394", "199", "155", "126", "11", "28"],
        ["Passengers per year (in millions)", "775", "1191", "1927", "144", "45", "50"]
    ], //1 - mbar
    [   //Probably will never pass
        ["No", "1,", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
        ["Uncertainty Parmeters", "Residual oil saturation", "Endpoint Krw", "Polymer viscosity", "Polymer adsorption", "Permeability reduction", "Inaccesible pore volume", "Shear thinning", "Surfactant Adsorption (mg/g)", "Microemulsion viscosity (cp)", "Sor: High capillary number"],
        ["Low", "0.15", "0.1", "7", "70", "1.3", "0.9", "Low", "0.5", "25", "0.06"],
        ["Mid", "0.225", "0.25", "10", "50", "1.2", "0.95", "Mid", "0.3", "18", "0.03"],
        ["High", "0.3", "0.4", "12", "30", "1", "1", "High", "0.15", "14", "0.01"]
    ], //2 - mbar
    [   //Will never pass GraphEngine
        ["", "TEAM A", "TEAM B", "TEAM C", "TEAM D"],
        ["Ogun State", "105", "15", "55", "0"],
        ["Oyo State", "0", "0", "0", "0"],
        ["Ekiti State", "55", "25", "0", "5"],
        ["Lagos State", "15", "75", "10", "0"],
        ["Remarks", "", "", "", ""]
    ], //3 - mbar
    [
        ["NUMBER OF CDS", "0 TO 4", "5 TO 9", "10 TO 14", "15 TO 19"],
        ["FREQUENCY, F", "10", "12", "6", "2"],
        ["MID-POINT, X", "2", "7", "12", "17"],
        ["FX", "20", "84", "72", "34"]
    ], //4 - mbar
    [   //Good example - note that blank top right is fairly common
        ["", "France", "Germany", "UK", "Turkey", "Spain"],
        ["Food and drink", "25%", "22%", "27%", "36%", "31%"],
        ["Housing", "31%", "33%", "37%", "20%", "18%"],
        ["Clothing", "7%", "15%", "11%", "12%", "8%"],
        ["Entertainment", "13%", "19%", "11%", "10%", "15%"]
    ], //5 - mbar
    [   //Highly unlikely to pass because of the diagonally slashed cell
        ["", "skill", "Html", "mySQl", "C", "C++", "SQL"],
        ["Division Ratio = 0.2", "Pass", "0.91", "0.9", "0.98", "0.94", "0.85"],
        ["Division Ratio = 0.2", "Fail", "0.09", "0.1", "0.02", "0.06", "0.15"],
        ["Division Ratio = 0.25", "Pass", "0.9", "0.93", "0.97", "0.93", "0.82"],
        ["Division Ratio = 0.25", "Fail", "0.1", "0.07", "0.03", "0.07", "0.18"]
    ], //6 - mbar
    [
        ["What flavor of ice cream would you pick?", "", "Children", "Teens", "Adults", "Total"],
        ["What flavor of ice cream would you pick?", "Chocolate", "40", "12", "55", "107"],
        ["What flavor of ice cream would you pick?", "Vanilla", "22", "16", "54", "92"],
        ["What flavor of ice cream would you pick?", "Neither", "15", "45", "10", "70"]
    ], //7 - mbar
    [   //Good one if title is stripped
        ["Object", "A", "B", "C", "D"],
        ["Mass (kg)", "4.0", "6.0", "8.0", "16.0"],
        ["Speed (m/s)", "6.0", "5.0", "3.0", "1.5"]
    ], //8 - mbar
    [
        ["", "X", "Y", "Z"],
        ["A", "$40", "$50", "$60"],
        ["B", "240", "200", "310"],
        ["C", "48", "59", "79"]
    ], //9 - mbar
    [   //Reasonably good
        ["", "First Class Passengers", "Second Class Passengers", "Third Class Passengers", "Total Passengers"],
        ["Survived", "201", "118", "181", "500"],
        ["Did Not Survived", "123", "166", "528", "817"],
        ["Total", "324", "284", "709", "1317"]
    ], //10 - mbar
    [   //Probably will not pass GraphEngine soon, possibly add blank col ignorer code?
        ["Interval", "91-100", "101-110", "111-120", "121-130", "131-140", "141-150", "151-160"],
        ["Frequency", "6", "3", "0", "3", "0", "2", "2"],
        ["Cumulative Frequency", "", "", "", "", "", "", ""]
    ], //11 - mline
    [
        ["County", "September", "October", "November", "December"],
        ["County 1", "107", "109", "135", "148"],
        ["County 2", "182", "173", "156", "153"],
        ["Total", "289", "282", "291", "301"]
    ], //12 - mline
    [
        ["Month", "Number of toy cars sold (frequency)", "Total number of toy cars sold (Cumulative frequency)"],
        ["January", "20", "20"],
        ["February", "30", "50"],
        ["March", "25", "75"],
        ["April", "10", "85"],
        ["May", "40", "125"],
        ["June", "35", "160"]
    ], //13 - mline
    [
        ["Name/Technique", "SVM", "Naïve Bayes", "Associative Classifier", "ACO based classifier"],
        ["Leukemia", "95", "93", "96", "100"],
        ["Lung", "81", "91", "93", "34"],
        ["Prostate", "90", "76", "89", "100"]
    ], //14
    [
        ["", "A", "B", "C", "D"],
        ["1", "", "2008", "2009", "2010"],
        ["2", "Jan", "230", "442", "710"],
        ["3", "Feb", "255", "527", "750"],
        ["4", "Mar", "319", "573", "810"],
        ["5", "Apr", "335", "575", "766"],
        ["6", "May", "277", "579", "850"],
        ["7", "Jun", "372", "620", "897"],
        ["8", "Jul", "396", "583", "897"],
        ["9", "Aug", "359", "637", "892"],
        ["10", "Sep", "428", "707", "958"],
        ["11", "Oct", "402", "697", ""],
        ["12", "Nov", "485", "696", ""],
        ["13", "Dec", "467", "798", ""],
        ["14", "", "", "", ""],
    ], //15
    [
        ["Name/Technique", "SVM", "Naïve Bayes", "Associative Classifier", "ACO based classifier"],
        ["Leukemia", "95", "96", "97", "98"],
        ["Lung", "81", "91", "93", "34"],
        ["Prostate", "90", "76", "89", "100"]
    ], //16 - 14 modified to have internal arithmetic sequence
]

func reformatArr(arr: [[[String]]]) -> [[[String]]] { //because i wrote arrs in wrong format for 2d
    var new:[[[String]]] = []
    for table in arr {
        var newTable:[[String]] = []
        var colOne:[String] = []
        var colTwo:[String] = []
        for row in table {
            colOne.append(row[0])
            colTwo.append(row[1])
        }
        newTable.append(colOne)
        newTable.append(colTwo)
        new.append(newTable)
    }
    return new
}

var twoColTables:[[[String]]] = [
    [
        ["Month", "Number of toy cars sold (frequency)"],
        ["January", "20"],
        ["February", "30"],
        ["March", "25"],
        ["April", "10"],
        ["May", "40"],
        ["June", "35"]
    ], //0 - line, bar - good
    [
        ["Time, t (sec)", "Height, H (meters)"],
        ["0.0", "7.3"],
        ["0.5", "9.5"],
        ["1.0", "12.8"],
        ["1.5", "14.3"],
        ["2.0", "16.5"],
        ["2.5", "19.0"],
        ["3.0", "21.2"]
    ], //1 - line, bar - good
    [
        ["Month", "Average Temp."],
        ["Jan", "30"],
        ["Feb", "26"],
        ["Mar", "42"],
        ["Apr", "58"]
    ], //2 - line, bar - good
    [
        ["HEIGHT (CM)", "FREQUENCY"],
        ["65 < h ≤ 75", "2"],
        ["75 < h ≤ 80", "7"],
        ["80 < h ≤ 90", "21"],
        ["90 < h ≤ 105", "15"],
        ["105 < h ≤ 110", "12"]
    ], //3 - line/bar - does bar
    [
        ["Water Depth (meters)", "Temperature (C)"],
        ["50", "18"],
        ["75", "15"],
        ["100", "12"],
        ["150", "5"],
        ["200", "4"]
    ], //4 - bar (does scatter)
    [
        ["x", "y"],
        ["-3", "-6"],
        ["-1", "-4"],
        ["2", "-1"],
        ["4", "1"],
        ["5", "2"]
    ], //5 - scatter (good)
    [
        ["x", "f(x)"],
        ["-2", "-8"],
        ["-1", "0"],
        ["0", "0"],
        ["1", "-2"],
        ["2", "0"],
        ["3", "12"]
    ], //6 - line (good)
    [
        ["Month", "Revenue"],
        ["JAN", "$28,361"],
        ["FEB", "$14,744"],
        ["MAR", "$19,407"],
        ["APR", "$15,891"],
        ["MAY", "$21,277"],
        ["JUN", "$21,530"],
        ["JUL", "$17,990"],
        ["AUG", "$21,838"],
        ["SEP", "$20,174"],
        ["OCT", "$20,025"],
        ["NOV", "$48,055"],
        ["DEC", "$24,318"]
    ], //7 - line
    [
        ["x", "y"],
        ["11", "27"],
        ["12", "29"],
        ["13", "31"],
        ["14", "33"],
        ["15", "35"]
    ], //8 - line, bar
    [
        ["Weight (Kg)", "Frequency"],
        ["60 up to 70", "13"],
        ["70 up to 75", "2"],
        ["75 up to 95", "45"],
        ["95 up to 100", "7"]
    ], //9 - bar, should be line
    [
        ["Method of Traveling", "Number of children"],
        ["Walking", "8"],
        ["Car", "9"],
        ["Bus", "4"],
        ["Cycle", "5"],
        ["Train", "1"],
        ["Taxi", "3"]
    ], //10 - bar, good
    [
        ["Baseball Team Runs Per Inning", "Baseball Team Runs Per Inning"],
        ["Number of Runs", "Frequency"],
        ["0", "4"],
        ["1", "3"],
        ["2", "1"],
        ["3", "1"]
    ], //11 - line, bar, good
    [
        ["The Graph", "The Graph"],
        ["Salt Concentration", "Transmittance"],
        ["3", "85.43"],
        ["6", "50"],
        ["9", "33.45"]
    ], //12 - line, good
    [
        ["Size", "Size"],
        ["Height", "Width"],
        ["5", "2.2"],
        ["4", "3.3"],
        ["1", "5"]
    ] //13 - scatter, good
]

//  ["", ""]

//≥
//≤
