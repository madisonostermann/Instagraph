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

class ImageProcessingEngine: NSObject {
    @ObservedObject var ocrProperties: OCRProperties
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
            //.tesseractOnly = fastest but least accurate method
            //.cubeOnly = slower but more accurate since it employs more AI
            //.tesseractCubeCombined = runs both .tesseractOnly & .cubeOnly; slowest but most accurate
            tesseract.pageSegmentationMode = .auto //lets it know how the text is divided- paragraph breaks
            tesseract.image = scaledImage //preprocessedImage
            //tesseract.recognize()
            //print(tesseract.recognizedText)
            
            ///hOCR gets html/text that orders text in columns from left to right
            let hOCR = tesseract.recognizedHOCR(forPageNumber: 1)
            print(hOCR!)
            sortText(hOCR: hOCR!)
        }
        //self.ocrProperties.page = "Results"
        self.ocrProperties.page = "Graph"
    }
    
    func sortText(hOCR: String) {
        ///find all stuff we care about and add to the 'words' array- filter out excess html stuff
        let words:[String] = matches(for: "(?<='eng'>)[a-zA-Z0-9!@#$&()\\-`.+,/\"]*|([^<>]+(?=</))", in: hOCR)
        ///find all x_locations of those words through the bounding box attribute- returns "start_x start_y end_x end_y"
        let bBox = matches(for: "((?<='bbox )[^<>]+(?=;))", in: hOCR)
        ///because some words will be useless (empty or whitespace), the word & bBox won't match
        ///only add viable words to filteredWords and save start_y location at corresponding position in y array
        var filteredWords = [String]()
        var y = [Int]()
        var counter = 0
        for i in words.indices {
            if words[i] != "" && !words[i].trimmingCharacters(in: .whitespaces).isEmpty && !words[i].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                filteredWords.append(words[i])
                var bBoxSplit = bBox[counter].split(separator: " ")
                var startY = Int(bBoxSplit[1].components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
                if startY != 0 { y.append(startY) }
                startY = 0
                bBoxSplit = []
                counter += 1
            }
        }
        ///if the y location of two adjacent words is the same (or super close), it means they're on the same line and shouldn't be in different array elements
        var i = 0
        while i < y.count-2 {
            if y[i]-y[i+1] < 20 && y[i]-y[i+1] > -20 {
                filteredWords[i] += " "
                filteredWords[i] += filteredWords[i+1]
                filteredWords.remove(at: i+1)
                y.remove(at: i+1)
            } else { i += 1 } /// if the comparison combined the two, don't move on because you still need to combine the new one + the next
        }
        ///if the y location of two adjacent words are significantly different, it means its in a different column, so we create a new inner array for that column
        var dataArrays = [[String]](repeating: [String](repeating: "", count: filteredWords.count), count: filteredWords.count)
        var colValues = 0
        var colNum = 0
        for i in 0...y.count-1 {
            ///if the arrays aren't the same size (should be corrected for in previous verification), send message and abort (will get index out of bounds)
            if filteredWords.count != y.count {
                print("Conflict in number of words and x locations. Aborting.")
                print("Number of words: ", filteredWords.count)
                print("Number of y locations: ", y.count)
                break
            }
            ///check if there will be a next element before comparing i & i+1
            ///change in y --> create new inner array and reset first value used in new inner array to 0
            if i < y.count-1 && (y[i]-y[i+1] > 100 || y[i]-y[i+1] < -100) {
                dataArrays[colNum][colValues] = filteredWords[i]
                colValues = 0
                colNum += 1
            } else {
                dataArrays[colNum][colValues] = filteredWords[i]
                colValues += 1
            }
        }
        ///because dataArrays was created with extra "" elements, go back through &  clean it up
        for i in dataArrays.indices { dataArrays[i].removeAll(where: { $0 == "" })}
        ///Create a printable string from the array- not needed for processing, but nice to see on screen for testing
        var all_words = ""
        for word in filteredWords {
            all_words += word
            all_words += " "
        }
        print(filteredWords)
        print(y)
        print(dataArrays)
        ///pass dataArrays to graphing engine and display text for testing purposes
        self.ocrProperties.dataArray = dataArrays
        ocrProperties.text = (all_words != "" ? all_words : "No text recognized.")
    }
    
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
}

//To scale image for Tesseract
//UIImage Extension allows access to any of its methods directly through a UIImage object
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
