//
//  OCRSortingEngine.swift
//  Instagraph
//
//  Created by Madison Gipson on 6/2/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import TesseractOCR
import GPUImage
import MobileCoreServices

class OCRSortingEngine: NSObject {
    @ObservedObject var ocrProperties: OCRProperties
    var cellContents = [String]()
    var locationColumns = [[CGFloat]]()
//    var contentColumns = [[String]]() //TODO: make this an ocrProperties value
    
    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pipeline() {
//        print("textLocations count: ", self.ocrProperties.textLocations!.count)
//        print("textLocations: ", self.ocrProperties.textLocations!)
//        print("cropped images count: ", self.ocrProperties.croppedImages!.count)
        //recognize text- get cellContents array
        ocr()
        print("textLocations count: ", self.ocrProperties.textLocations!.count)
        print("textLocations: ", self.ocrProperties.textLocations!)
        print("cellContents count: ", cellContents.count)
        print("cellContents: ", cellContents)
        //sort cellContents array by x value
        quickSort(sort: "x", low: 0, high: self.ocrProperties.textLocations!.count-1, row: 0)
        print("x sorted: ", cellContents)
        //splice cellContents array into separate columns (locationColumns & self.ocrProperties.contentColumns)
        divideColumns()
        print("columns divided: ", self.ocrProperties.contentColumns)
        //sort locationColumns & self.ocrProperties.contentColumns arrays by y value
        for row in 0...locationColumns.count-1 {
            quickSort(sort: "y", low: 0, high: locationColumns[row].count-1, row: row)
        }
        print("y sorted: ", self.ocrProperties.contentColumns)
        //present graph view, uses self.ocrProperties.contentColumns array for values
        self.ocrProperties.page = "Graph"
    }
    
    func ocr() {
        var imageCount = 0
        var textLocationsCount = 0
        //loop through individual cell images and get OCR
        for image in self.ocrProperties.croppedImages! {
            if let tesseract = G8Tesseract(language: "eng") {
                tesseract.engineMode = .tesseractCubeCombined
                tesseract.pageSegmentationMode = .auto //lets it know how the text is divided- paragraph breaks
                tesseract.image = image
                //hOCR gets html/text
                let hOCR = tesseract.recognizedHOCR(forPageNumber: 1)
                //extract all text from OCR reading
                let text = matches(for: "(?<='eng'>)[a-zA-Z0-9!@#$&()\\-`.+,/\"]*|([^<>]+(?=</))", in: hOCR!)
                //go through extracted text for a cell and see if there's any text there
                var noContent = true
                var thisCell = ""
//                print("imageCount: ", imageCount)
//                print("textlocations count: ", self.ocrProperties.textLocations!.count)
                for i in text.indices {
                    //remove whitespaces and see if there's anything
                    if text[i] != "" && !text[i].trimmingCharacters(in: .whitespaces).isEmpty && !text[i].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if noContent { //if there hasn't been any content before, initialize thisCell with the first text found
                            thisCell = text[i]
                        } else { //if there's already content, add a space and append the new content
                            thisCell += (" " + text[i])
                        }
                        noContent = false //let us know that some content was found
                    }
                }
                //if no content was found in this cell, remove the corresponding textLocation from array so things stay synchronized
                //otherwise add the cell contents to array
                if noContent {
                    self.ocrProperties.textLocations!.remove(at: textLocationsCount) //remove NSPoint at i if there's no words at that corresponding location after all
//                    print("REMOVING TEXT LOCATION AT: ", textLocationsCount)
                } else {
                    cellContents.append(thisCell)
                    textLocationsCount += 1
                }
            }
            imageCount += 1
        }
    }
    
    //used in ocr method for parsing the HTML for words & bbox info
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map { String(text[Range($0.range, in: text)!]) }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func quickSort(sort: String, low: Int, high: Int, row: Int) {
        if (low < high) {
            let partition_index:Int = partition(sort: sort, low: low, high: high, row: row)
            quickSort(sort: sort, low: low, high: partition_index-1, row: row)  //before partition_index
            quickSort(sort: sort, low: partition_index+1, high: high, row: row) //after partition_index
        }
    }
    
    func partition (sort: String, low: Int, high: Int, row: Int) -> Int {
        var pivot:CGFloat = 0 //element to be placed at right position
        var current_element:CGFloat = 0
        var smaller_index = (low - 1)  //index of smaller element
        
        if sort == "x" {
            pivot = self.ocrProperties.textLocations![high].cgPointValue.x
            for j in low...high-1 {
                current_element = self.ocrProperties.textLocations![j].cgPointValue.x
                //if current element is smaller than the pivot
                if (current_element < pivot) {
                    smaller_index += 1  // increment index of smaller element
                    self.ocrProperties.textLocations!.swapAt(smaller_index, j)
                    cellContents.swapAt(smaller_index, j)
                }
            }
            self.ocrProperties.textLocations!.swapAt(smaller_index+1, high)
            cellContents.swapAt(smaller_index+1, high)
        } else if sort == "y" {
            pivot = locationColumns[row][high]
            for j in low...high-1 {
                current_element = locationColumns[row][j]
                //if current element is smaller than the pivot
                if (current_element < pivot) {
                    smaller_index += 1    // increment index of smaller element
                    locationColumns[row].swapAt(smaller_index, j)
                    self.ocrProperties.contentColumns[row].swapAt(smaller_index, j)
                }
            }
            locationColumns[row].swapAt(smaller_index+1, high)
            self.ocrProperties.contentColumns[row].swapAt(smaller_index+1, high)
        }
        return (smaller_index + 1)
    }
    
    func divideColumns() {
        var singleLocationColumn = [CGFloat]()
        var singleContentColumn = [String]()
        for i in 0...self.ocrProperties.textLocations!.count-1 {
            let point = self.ocrProperties.textLocations![i].cgPointValue
            //if you're not at the first or the last value, compare last one to this one and add this one to a new column if reqs are met
            if i > 0 && i < self.ocrProperties.textLocations!.count-1 {
                let lastPoint = self.ocrProperties.textLocations![i-1].cgPointValue
                if lastPoint.x+10 < point.x { //TODO: generalize this x differences
                    //add last column to all columns
                    locationColumns.append(singleLocationColumn)
                    self.ocrProperties.contentColumns.append(singleContentColumn)
                    //remove elements to start a fresh new column
                    singleLocationColumn.removeAll()
                    singleContentColumn.removeAll()
                }
            }
            //add this point to the a new/existing column
            singleLocationColumn.append(point.y)
            singleContentColumn.append(cellContents[i])
            //if you're at the last value, make sure to add this column to all columns
            if i == self.ocrProperties.textLocations!.count-1 {
                locationColumns.append(singleLocationColumn)
                self.ocrProperties.contentColumns.append(singleContentColumn)
            }
        }
    }
}
