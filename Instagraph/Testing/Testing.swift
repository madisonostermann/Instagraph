//
//  Testing.swift
//  Instagraph
//
//  Created by Lannie Hough on 9/25/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation

class Testing {
    
    //Make array of images
    static var imagesOcrProperties:[OCRProperties] = [] //Properties for each image being loaded in
    
    //ImagePickerCoordinator in ImagePicker.swift analog - sends image through OpenCV
    //static var images:[UIImage] = []
    
    static func runTestingPipeline() {
        Testing.loadImages()
        Testing.processImages()
        print(Testing.percentCorrect(arr: Testing.ocrOutputResults).1)
    }
    
    static func loadImages() {
        for i in 1 ... 18 { //16 images in TestTables
            //Initialize new OCRProperties for each image
            let ocrP = OCRProperties()
            Testing.imagesOcrProperties.append(ocrP)//[i-1] = ocrP
                
            //load image
            //set image to appropriate OCRProperties instance
            ocrP.image = UIImage(named: "\(String(i))")
            
            //Initialize result arrays to false
            Testing.ocrOutputResults.append(false)//[i-1] = false
            Testing.engineOutputResults.append(false)//[i-1] = false
        }
    }
    
    static func processImages() {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectory)
        
        for i in 0 ..< 18 {
            print("-----------------------------------")
            print("IMAGE ", i+1, " IN TESTING PIPELINE")
            let ocrPInUse = Testing.imagesOcrProperties[i]
            
            do {
                let fileURL3 = documentsDirectory.appendingPathComponent(String(i+1)+"original.jpg")
                if let data3 = ocrPInUse.image?.jpegData(compressionQuality:  1.0),
                  !FileManager.default.fileExists(atPath: fileURL3.path) {
                    do {
                        try data3.write(to: fileURL3)
                    } catch {
                        print("error saving file:", error)
                    }
                }
                
                ocrPInUse.image = PrepareImageBridge().deskew(ocrPInUse.image)
                print("deskewed")
                
                let fileURL = documentsDirectory.appendingPathComponent(String(i+1)+"processed.jpg")
                if let data = ocrPInUse.image?.jpegData(compressionQuality:  1.0),
                  !FileManager.default.fileExists(atPath: fileURL.path) {
                    do {
                        try data.write(to: fileURL)
                    } catch {
                        print("error saving file:", error)
                    }
                }
                
                ocrPInUse.croppedImages = PrepareImageBridge().splice_cells() as NSArray as? [UIImage]
                ocrPInUse.textLocations = PrepareImageBridge().locate_cells() as? [NSValue]
                print("generated croppedImages and textLocations")
                
                if ocrPInUse.croppedImages!.count > 0 {
                    for j in 0 ... ocrPInUse.croppedImages!.count-1 {
                        let newDir = documentsDirectory.appendingPathComponent(String(i+1)).path
                        do{
                            try FileManager.default.createDirectory(atPath: newDir,withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                        let fileURL2 = documentsDirectory.appendingPathComponent(String(i+1)).appendingPathComponent(String(j+1)+"cropped.jpg")
                        if let data2 = ocrPInUse.croppedImages![j].jpegData(compressionQuality:  1.0),
                          !FileManager.default.fileExists(atPath: fileURL2.path) {
                            do {
                                try data2.write(to: fileURL2)
    //                            print("file saved")
                            } catch {
                                print("error saving file:", error)
                            }
                        }
                    }
                    
                    OCRSortingEngine(ocrProperties: ocrPInUse).pipeline()
                } else {
                    print("NO CROPPED IMAGES RETURNED")
                }
            } catch let error {
                print("Exception for image \(String(i+1)) while testing OpenCV and OCR!!!")
                print(error)
            }
            checkIf: if ocrPInUse.contentColumns == Testing.correctOcrOutputs[i] {
                Testing.ocrOutputResults[i] = true
                //Test GraphEngine on actual OCR output
//                let ge = GraphEngine(table: ocrPInUse.contentColumns)
//
//                do {
//                    let result = ge.determineGraphType()
//                    if result.0 == .failure {
//                        break checkIf
//                    }
//                    if Testing.areGraphsEqual(g1: result.1[0], g2: correctEngineOutput[i]) {
//                        engineOutputResults[i] = true
//                    }
//                } catch let error {
//                    print("Exception for determining graph type of image \(String(i+1))!")
//                    print("Error")
//                }
            }
        }
        
//        doFor: for i in 0 ..< 18 {
//            //Test GraphEngine on correct OCR output
//            let ge = GraphEngine(table: Testing.correctOcrOutputs[i])
//            do {
//                let result = ge.determineGraphType()
//                if result.0 == .failure {
//                    break doFor
//                }
//                if Testing.areGraphsEqual(g1: result.1[0], g2: correctEngineOutput[i]) {
//                    engineOutputResultsForCleanInput[i] = true
//                }
//            } catch let error {
//                print("Clean input: Exception for determining graph type of image \(String(i+1))!")
//                print("Error")
//            }
//        }
        
    }
    
    static func areGraphsEqual(g1: Graph, g2: Graph) -> Bool {
        if type(of: g1) != type(of: g2) {
            return false
        }
        if g1 is BarGraph {
            if g1 as! BarGraph == g2 as! BarGraph {
                return true
            }
        } else if g1 is LineGraph {
            if g1 as! LineGraph == g2 as! LineGraph {
                return true
            }
        } else if g2 is ScatterPlot {
            if g1 as! ScatterPlot == g2 as! ScatterPlot {
                return true
            }
        }
        return false
    }
    
    static func percentCorrect(arr: [Bool]) -> (Double, String) {
        var numTrue = 0
        for ele in arr {
            numTrue = ele ? numTrue + 1 : numTrue
        }
        let percent:Double = (Double(numTrue) / Double(arr.count))*100.0
        let percentString = String(percent)
        return (percent, percentString)
    }
    
    static var correctOcrOutputs:[[[String]]] = [
        [   //Good example once ï is sorted out and European commas are accounted for
            ["Method", "Naïve Bayes", "C45", "GOV", "DOG", "RF_CT"],
            ["Classification Accuracy (%)", "58,3", "69,8", "71,2", "71,4", "87,7"],
            ["Standard Deviation", "1,5", "4,7", "2,9", "2,6", "0,6"]
        ], //1
        [
            ["City", "London", "Paris", "Tokyo", "Washington DC", "Kyoto", "Los Angeles"],
            ["Date opened", "1863", "1900", "1927", "1976", "1981", "2001"],
            ["Kilometres of route", "394", "199", "155", "126", "11", "28"],
            ["Passengers per year (in millions)", "775", "1191", "1927", "144", "45", "50"]
        ],
        [   //Probably will never pass
            ["No", "1,", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
            ["Uncertainty Parmeters", "Residual oil saturation", "Endpoint Krw", "Polymer viscosity", "Polymer adsorption", "Permeability reduction", "Inaccesible pore volume", "Shear thinning", "Surfactant Adsorption (mg/g)", "Microemulsion viscosity (cp)", "Sor: High capillary number"],
            ["Low", "0.15", "0.1", "7", "70", "1.3", "0.9", "Low", "0.5", "25", "0.06"],
            ["Mid", "0.225", "0.25", "10", "50", "1.2", "0.95", "Mid", "0.3", "18", "0.03"],
            ["High", "0.3", "0.4", "12", "30", "1", "1", "High", "0.15", "14", "0.01"]
        ],
        [   //Will never pass GraphEngine
            ["", "TEAM A", "TEAM B", "TEAM C", "TEAM D"],
            ["Ogun State", "105", "15", "55", "0"],
            ["Oyo State", "0", "0", "0", "0"],
            ["Ekiti State", "55", "25", "0", "5"],
            ["Lagos State", "15", "75", "10", "0"],
            ["Remarks", "", "", "", ""]
        ],
        [
            ["NUMBER OF CDS", "0 TO 4", "5 TO 9", "10 TO 14", "15 TO 19"],
            ["FREQUENCY, F", "10", "12", "6", "2"],
            ["MID-POINT, X", "2", "7", "12", "17"],
            ["FX", "20", "84", "72", "34"]
        ],
        [   //Good example - note that blank top right is fairly common
            ["", "France", "Germany", "UK", "Turkey", "Spain"],
            ["Food and drink", "25%", "22%", "27%", "36%", "31%"],
            ["Housing", "31%", "33%", "37%", "20%", "18%"],
            ["Clothing", "7%", "15%", "11%", "12%", "8%"],
            ["Entertainment", "13%", "19%", "11%", "10%", "15%"]
        ],
        [], //7 - Too deviant
        [   //Highly unlikely to pass because of the diagonally slashed cell
            ["", "skill", "Html", "mySQl", "C", "C++", "SQL"],
            ["Division Ratio = 0.2", "Pass", "0.91", "0.9", "0.98", "0.94", "0.85"],
            ["Division Ratio = 0.2", "Fail", "0.09", "0.1", "0.02", "0.06", "0.15"],
            ["Division Ratio = 0.25", "Pass", "0.9", "0.93", "0.97", "0.93", "0.82"],
            ["Division Ratio = 0.25", "Fail", "0.1", "0.07", "0.03", "0.07", "0.18"]
        ],
        [   //Super easy
            ["x", "11", "12", "13", "14", "15"],
            ["y", "27", "29", "31", "33", "35"]
        ],
        [], //10 - Too deviant
        [
            ["What flavor of ice cream would you pick?", "", "Children", "Teens", "Adults", "Total"],
            ["What flavor of ice cream would you pick?", "Chocolate", "40", "12", "55", "107"],
            ["What flavor of ice cream would you pick?", "Vanilla", "22", "16", "54", "92"],
            ["What flavor of ice cream would you pick?", "Neither", "15", "45", "10", "70"]
        ],
        [   //Solid goal, thin lines but otherwise good - could work already as a 2xN table
            ["Month", "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"],
            ["Revenue", "$28,361", "$14,744", "$19,407", "$15,891", "$21,277", "$21,530", "$17,990", "$21,838", "$20,174", "$20,025", "$48,055", "$24,318"]
        ],
        [   //Good one if title is stripped
            ["Object", "A", "B", "C", "D"],
            ["Mass (kg)", "4.0", "6.0", "8.0", "16.0"],
            ["Speed (m/s)", "6.0", "5.0", "3.0", "1.5"]
        ], //13
        [
            ["", "X", "Y", "Z"],
            ["A", "$40", "$50", "$60"],
            ["B", "240", "200", "310"],
            ["C", "48", "59", "79"]
        ],
        [   //Reasonably good
            ["", "First Class Passengers", "Second Class Passengers", "Third Class Passengers", "Total Passengers"],
            ["Survived", "201", "118", "181", "500"],
            ["Did Not Survived", "123", "166", "528", "817"],
            ["Total", "324", "284", "709", "1317"]
        ],
        [   //Probably will not pass GraphEngine soon, possibly add blank col ignorer code?
            ["Interval", "91-100", "101-110", "111-120", "121-130", "131-140", "141-150", "151-160"],
            ["Frequency", "6", "3", "0", "3", "0", "2", "2"],
            ["Cumulative Frequency", "", "", "", "", "", "", ""]
        ], //16
        [   //Should pass
            ["Month", "Jan", "Feb", "Mar", "Apr"],
            ["Average Temp.", "30", "26", "42", "58"]
        ],
        [   //Should pass
            ["Gamer", "Zac", "Sam", "Zoe", "Oscar", "Sue"],
            ["Score", "55", "25", "52", "67", "23"]
        ]
    ]
    static var ocrOutputResults:[Bool] = []
    
    static var correctEngineOutput:[Graph] = []
    static var engineOutputResults:[Bool] = []
    static var engineOutputResultsForCleanInput:[Bool] = []
    
}








//class OCRProperties: ObservableObject {
//    @Published var page: String = "Home"
//    @Published var source = ""
//    @Published var image: UIImage? = nil
//    @Published var croppedImages: [UIImage]? = []
//    @Published var textLocations: [NSValue]? = []
//    @Published var finalImage: Image? = nil
//    @Published var text: String = ""
//    //@Published var dataArray: [[String]] = [[String]](repeating: [String](repeating: "", count: 1), count: 1)
//    @Published var contentColumns = [[String]]()
//}
