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
            GraphEngine.reformatEuropean(arr: &t)
            print(t)
            let g = GraphEngine(table: t)
            let result = g.checkTemporalComplex(table: g.rawTable)
            print(String(i) + ": " + String(result))
            i += 1
        }
        print(Constants.ALL_MONTHS)
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
    ], //11 - mbar
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
        ["", "", "", "", ""],
        ["", "", "", "", ""],
        ["", "", "", "", ""]
    ], //14
    [
        
    ] //15
]
