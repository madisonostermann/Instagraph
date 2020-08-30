//
//  ImageProcessingEngine.swift
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

// driven by performImageRecognition: performs OCR and calls the following methods
// 1. sanitize (the hOCR): parse HTML, sanitize for non-viable html components, then create data structures storing extracted text & their corresponding locations
        // a. matches: parse the HTML for words & bbox info
// 2. group: group text that may have been picked up as separate elements into the same cell, depending on location
// 3. sortX: DOESN'T DO ANYTHING RIGHT NOW
// 4. divideColumns: delineate columns based on y location of adjacent words- divide into inner arrays

class ImageProcessingEngine: NSObject {
    @ObservedObject var ocrProperties: OCRProperties
    var filteredWords = [String]()
    var startx = [Int]()
    var endx = [Int]()
    var starty = [Int]()
    var dataArrays = [[String]]()
    
    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func performImageRecognition() {
        //by the time it gets here, i think it won't need to be processed at all because it will have already gone through opencv
        let scaledImage = ocrProperties.image!.scaledImage(1000) ?? ocrProperties.image!
        //let preprocessedImage = scaledImage.preprocessedImage() ?? scaledImage
        ocrProperties.finalImage = Image(uiImage: scaledImage) //preprocessedImage
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto //lets it know how the text is divided- paragraph breaks
            tesseract.image = scaledImage //preprocessedImage
            
            ///hOCR gets html/text that orders text in columns from left to right
            let hOCR = tesseract.recognizedHOCR(forPageNumber: 1)
            print(hOCR!)
            
            sanitize(hOCR: hOCR!)
            group(scaledImage: scaledImage)
            //sortX()
            divideColumns(scaledImage: scaledImage)
        }
        print("===================== ACCURACY TESTING =========================")
        print("================== ARRAY OUTPUT AFTER OCR ======================")
        print(self.ocrProperties.dataArray)
        print("==============================================")
        self.ocrProperties.page = "Graph"
    }
    
    ///parse HTML, sanitize for non-viable html components, then create data structures storing extracted text & their corresponding locations
    func sanitize(hOCR: String) {
        //parse HTML for text and location info
        let words:[String] = matches(for: "(?<='eng'>)[a-zA-Z0-9!@#$&()\\-`.+,/\"]*|([^<>]+(?=</))", in: hOCR)
        let bBox = matches(for: "((?<='bbox )[^<>]+(?=;))", in: hOCR)
        print("words prior to sanitization: ", words)
        print("words count: ", words.count)
        print("bBox prior to sanitization: ", bBox)
        print("bBox count: ", bBox.count)
        //filter out non-viable words + record their corresponding locations in arrays
        var counter = 0
        var bBoxSplit = [String.SubSequence]()
        var startX:Int
        var endX:Int
        var startY:Int
        for i in 0...5 {
        //for i in words.indices {
            if words[i] != "" && !words[i].trimmingCharacters(in: .whitespaces).isEmpty && !words[i].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    //only add words to filteredWords if they aren't empty
                    filteredWords.append(words[i])
                    //add the word's corresponding location to the different bbox arrays
                    //separate counter is used because there isn't any bbox info for words that are empty
                    bBoxSplit = bBox[counter].split(separator: " ")
                    startX = Int(bBoxSplit[0].components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
                    if startX != 0 { startx.append(startX) }
                    endX = Int(bBoxSplit[2].components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
                    if endX != 0 { endx.append(endX) }
                    startY = Int(bBoxSplit[1].components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
                    if startY != 0 { starty.append(startY) }
                    //move to the next bbox info
                    counter += 1
            }
        }
        print("words after sanitization: ", filteredWords)
        print("filteredWords count: ", filteredWords.count)
        print("startx (bBox info) after sanitization: ", startx)
        print("startx count: ", startx.count)
    }
    ///used in "sanitize" method for parsing the HTML for words & bbox info
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
    
    ///group text that may have been picked up as separate elements into the same cell, depending on location
    func group(scaledImage: UIImage) {
        //if the y & x locations of two adjacent words is the same (or super close), it means they're on the same line and shouldn't be in different array elements
        var i = 0
        while i < starty.count-2 {
            if starty[i]-starty[i+1] < Int(scaledImage.size.height/50) && starty[i]-starty[i+1] > -(Int(scaledImage.size.height/50)) && endx[i]-startx[i+1] < Int(scaledImage.size.height/50) && endx[i]-startx[i+1] > -(Int(scaledImage.size.height/50)) { //was 20
                filteredWords[i] += " "
                filteredWords[i] += filteredWords[i+1]
                filteredWords.remove(at: i+1)
                starty.remove(at: i+1)
                startx.remove(at: i+1)
                endx.remove(at: i+1)
            } else { i += 1 } //if the comparison combined the two, don't move on because you still need to combine the new one + the next
        }
    }
    
//    func sortX() {
//
//    }
    
    ///delineate columns based on y location of adjacent words- divide into inner arrays
    func divideColumns(scaledImage: UIImage) {
        //if the y location of two adjacent words are significantly different, it means its in a different column, so we create a new inner array for that column
        dataArrays = [[String]](repeating: [String](repeating: "", count: filteredWords.count), count: filteredWords.count)
        var colValues = 0
        var colNum = 0
        for i in 0...starty.count-1 {
            //if the arrays aren't the same size (should be corrected for in previous verification), send message and abort (will get index out of bounds)
            if filteredWords.count != starty.count {
                print("Conflict in number of words and x locations. Aborting.")
                print("Number of words: ", filteredWords.count)
                print("Number of y locations: ", starty.count)
                break
            }
            //check if there will be a next element before comparing i & i+1
            //change in y --> create new inner array and reset first value used in new inner array to 0
            if i < starty.count-1 && (starty[i]-starty[i+1] > Int(scaledImage.size.height/3) || starty[i]-starty[i+1] < -Int(scaledImage.size.height/3)) { //was 100
                dataArrays[colNum][colValues] = filteredWords[i]
                colValues = 0
                colNum += 1
            } else {
                dataArrays[colNum][colValues] = filteredWords[i]
                colValues += 1
            }
        }
        
        //because dataArrays was created with extra "" elements, go back through &  clean it up
        for i in dataArrays.indices { dataArrays[i].removeAll(where: { $0 == "" })}
        //pass dataArrays to graphing engine and display text for testing purposes
        self.ocrProperties.dataArray = { //dataArrays
            var arr:[[String]] = []
            for a in 0 ..< dataArrays.count {
                if !(dataArrays[a].count == 0) {
                    arr.append(dataArrays[a])
                }
            }
            return arr
        }()
    }
    
    ///just for testing
//    func testing() {
//        //Create a printable string from the array- not needed for processing, but nice to see on screen for testing
//        var all_words = ""
//        for word in filteredWords {
//            all_words += word
//            all_words += " "
//        }
//        print(filteredWords)
//        print(starty)
//        //print(dataArrays)
//        ocrProperties.text = (all_words != "" ? all_words : "No text recognized.")
//    }
    
}

///To scale image for Tesseract
///UIImage Extension allows access to any of its methods directly through a UIImage object
extension UIImage {
    func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        //Calculate the smaller dimension of the image such that scaledSize retains the image's aspect ratio
        if size.width > size.height {
            scaledSize.height = size.height / size.width * scaledSize.width
        } else {
            scaledSize.width = size.width / size.height * scaledSize.height
        }
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    /*func preprocessedImage() -> UIImage? {
        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
        // GPU Threshold Filter “determines the local luminance around a pixel, then turns the pixel black if it is below that local luminance, and white if above. This can be useful for picking out text under varying lighting conditions.”
        stillImageFilter.blurRadiusInPixels = 15.0 //defaults to 4.0
        let filteredImage = stillImageFilter.image(byFilteringImage: self)
        return filteredImage
    }*/
    
}
