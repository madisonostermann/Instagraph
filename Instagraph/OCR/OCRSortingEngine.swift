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
    var columnsY = [[CGFloat]]()
    var columns = [[String]]()
    
    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pipeline() {
        ocr() //recognize text- get cellContents array
        //sorting by x value
        quickSort(coord: "x", low: 0, high: self.ocrProperties.textLocations!.count-1, row: 0)
        print("x sorted")
        print(self.ocrProperties.textLocations!)
        print(cellContents)
        divideColumns()
        
        //sorting by y value
        for row in 0...columnsY.count-1 {
            quickSort(coord: "y", low: 0, high: columnsY[row].count-1, row: row)
        }
        print("y sorted")
        print(columnsY)
        print(columns)
        
        //self.ocrProperties.page = "Graph"
    }
    
    func ocr() {
        var imageCount = 0
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
                    self.ocrProperties.textLocations!.remove(at: imageCount) //remove NSPoint at i if there's no words at that corresponding location after all
                } else {
                    cellContents.append(thisCell)
                }
            }
            imageCount += 1
        }
        
        print("textLocations count: ", self.ocrProperties.textLocations!.count)
        for loc in self.ocrProperties.textLocations! {
            print(loc)
        }
        print("cellContents count: ", cellContents.count)
        for item in cellContents {
            print(item)
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
    
    /* low  --> Starting index,  high  --> Ending index */
    func quickSort(coord: String, low: Int, high: Int, row: Int) {
        if (low < high) {
            let partition_index:Int = partition(coord: coord, low: low, high: high, row: row)
            quickSort(coord: coord, low: low, high: partition_index-1, row: row)  //before partition_index
            quickSort(coord: coord, low: partition_index+1, high: high, row: row) //after partition_index
        }
    }
    
    /* This function takes last element as pivot, places
       the pivot element at its correct position in sorted
        array, and places all smaller (smaller than pivot)
       to left of pivot and all greater elements to right
       of pivot */
    func partition (coord: String, low: Int, high: Int, row: Int) -> Int {
        // pivot (Element to be placed at right position)
        var pivot:CGFloat = 0
        var current_element:CGFloat = 0
        
        if coord == "x" {
            //pivot = self.ocrProperties.textLocations![high].cgPointValue.x
            pivot = self.ocrProperties.textLocations![high].cgPointValue.x
        } else if coord == "y" {
            //pivot = self.ocrProperties.textLocations![high].cgPointValue.y //columnsY[0][high]
            pivot = columnsY[row][high]
        }
     
        var smaller_index = (low - 1)  // Index of smaller element

        for j in low...high-1 {
            if coord == "x" {
                current_element = self.ocrProperties.textLocations![j].cgPointValue.x//self.ocrProperties.textLocations![j].cgPointValue.x
            } else if coord == "y" {
                current_element = columnsY[row][j]//self.ocrProperties.textLocations![j].cgPointValue.y
            }
            // If current element is smaller than the pivot
            if (current_element < pivot) {
                smaller_index += 1    // increment index of smaller element
                if coord == "x" {
                    self.ocrProperties.textLocations!.swapAt(smaller_index, j)
                    cellContents.swapAt(smaller_index, j)
                } else if coord == "y" {
                    columnsY[row].swapAt(smaller_index, j)
                    columns[row].swapAt(smaller_index, j)
                }
            }
        }
        if coord == "x" {
            self.ocrProperties.textLocations!.swapAt(smaller_index+1, high)
            cellContents.swapAt(smaller_index+1, high)
        } else if coord == "y" {
            columnsY[row].swapAt(smaller_index+1, high)
            columns[row].swapAt(smaller_index+1, high)
        }
        return (smaller_index + 1)
    }
    
//    func partition (coord: String, low: Int, high: Int) -> Int {
//          // pivot (Element to be placed at right position)
//          var smaller_index = (low - 1) // Index of smaller element
//
//          if coord == "x" {
//              var array = self.ocrProperties.textLocations!
//              let pivot = array[high].cgPointValue.x
//              for j in low...high-1 {
//                  let current_element = array[j].cgPointValue.x
//                  if (current_element < pivot) {
//                      smaller_index += 1    // increment index of smaller element
//                      array.swapAt(smaller_index, j)
//                      cellContents.swapAt(smaller_index, j)
//                  }
//              }
//              array.swapAt(smaller_index+1, high)
//              cellContents.swapAt(smaller_index+1, high)
//          } else if coord == "y" {
//              var array = columnsY
//              let pivot = array[0][high]
//              for j in low...high-1 {
//                  let current_element = array[0][j]
//                  if (current_element < pivot) {
//                      smaller_index += 1    // increment index of smaller element
//                      array.swapAt(smaller_index, j)
//                      columns.swapAt(smaller_index, j)
//                  }
//              }
//              array.swapAt(smaller_index+1, high)
//              columns.swapAt(smaller_index+1, high)
//          }
//          return (smaller_index + 1)
//      }
    
    func divideColumns() {
        var columnY = [CGFloat]()
        var column = [String]()
        for i in 0...self.ocrProperties.textLocations!.count-1 {
            let point = self.ocrProperties.textLocations![i].cgPointValue
            if i == 0 {
                columnY.append(point.y) //columnsY[columnIndex][cell] = point.y
                column.append(cellContents[i])//columns[columnIndex][cell] = cellContents[i]
                //cell += 1
            } else if i == self.ocrProperties.textLocations!.count-1{
                columnY.append(point.y) //columnsY[columnIndex][cell] = point.y
                column.append(cellContents[i])//columns[columnIndex][cell] = cellContents[i]
                columnsY.append(columnY)
                columns.append(column)
            } else {
                let lastPoint = self.ocrProperties.textLocations![i-1].cgPointValue
                if lastPoint.x+10 < point.x { //TODO: generalize this x differences
                    columnsY.append(columnY)
                    columns.append(column)
                    //remove elements to start a fresh new column
                    columnY.removeAll()
                    column.removeAll()
                    //columnIndex += 1 //create a new column
                    //cell = 0
                }
                columnY.append(point.y) //columnsY[columnIndex][cell] = point.y
                column.append(cellContents[i])//columns[columnIndex][cell] = cellContents[i]
                //cell += 1
            }
        }
        
        //because arrays were created with extra elements, go back through &  clean them up
        for i in columnsY.indices { columnsY[i].removeAll(where: { $0 == 0.0 })}
        for i in columns.indices { columns[i].removeAll(where: { $0 == "" })}
        print(columnsY)
        print(columns)
    }
}
