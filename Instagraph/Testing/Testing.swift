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
    }
    
    static func loadImages() {
        for i in 1 ... 16 { //16 images in TestTables
            //Initialize new OCRProperties for each image
            let ocrP = OCRProperties()
            Testing.imagesOcrProperties[i-1] = ocrP
                
            //load image
            //set image to appropriate OCRProperties instance
            ocrP.image = UIImage(named: "\(String(i))")
            
            //Initialize result arrays to false
            Testing.ocrOutputResults[i-1] = false
            Testing.engineOutputResults[i-1] = false
        }
    }
    
    static func processImages() {
        
        for i in 0 ..< 16 {
            let ocrPInUse = Testing.imagesOcrProperties[i]
            do {
                ocrPInUse.image = PrepareImageBridge().deskew(ocrPInUse.image)
                ocrPInUse.croppedImages = PrepareImageBridge().splice_cells() as NSArray as? [UIImage]
                ocrPInUse.textLocations = PrepareImageBridge().locate_cells() as? [NSValue]
                OCRSortingEngine(ocrProperties: ocrPInUse)
            } catch let error {
                print("Exception for image \(String(i+1)) while testing OpenCV and OCR!!!")
                print(error)
            }
            checkIf: if ocrPInUse.dataArray == Testing.correctOcrOutputs[i] {
                Testing.ocrOutputResults[i] = true
                //Test GraphEngine on actual OCR output
                let ge = GraphEngine(table: ocrPInUse.dataArray)
                
                do {
                    let result = ge.determineGraphType()
                    if result.0 == .failure {
                        break checkIf
                    }
                    if Testing.areGraphsEqual(g1: result.1[0], g2: correctEngineOutput[i]) {
                        engineOutputResults[i] = true
                    }
                } catch let error {
                    print("Exception for determining graph type of image \(String(i+1))!")
                    print("Error")
                }
            }
        }
        
        doFor: for i in 0 ..< 16 {
            //Test GraphEngine on correct OCR output
            let ge = GraphEngine(table: Testing.correctOcrOutputs[i])
            do {
                let result = ge.determineGraphType()
                if result.0 == .failure {
                    break doFor
                }
                if Testing.areGraphsEqual(g1: result.1[0], g2: correctEngineOutput[i]) {
                    engineOutputResultsForCleanInput[i] = true
                }
            } catch let error {
                print("Clean input: Exception for determining graph type of image \(String(i+1))!")
                print("Error")
            }
        }
        
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
    
    static var correctOcrOutputs:[[[String]]] = [[]]
    static var ocrOutputResults:[Bool] = []
    
    static var correctEngineOutput:[Graph] = []
    static var engineOutputResults:[Bool] = []
    static var engineOutputResultsForCleanInput:[Bool] = []
    
    static func percentCorrect(arr: [Bool]) -> (Double, String) {
        var numTrue = 0
        for ele in arr {
            numTrue = ele ? numTrue + 1 : numTrue
        }
        let percent:Double = (Double(numTrue) / Double(arr.count))*100.0
        let percentString = String(percent)
        return (percent, percentString)
    }
    
}








//class OCRProperties: ObservableObject {
//    @Published var page: String = "Home"
//    @Published var source = ""
//    @Published var image: UIImage? = nil
//    @Published var croppedImages: [UIImage]? = []
//    @Published var textLocations: [NSValue]? = []
//    @Published var finalImage: Image? = nil
//    @Published var text: String = ""
//    @Published var dataArray: [[String]] = [[String]](repeating: [String](repeating: "", count: 1), count: 1)
//}
