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
        let preprocessedImage = scaledImage.preprocessedImage() ?? scaledImage
        ocrProperties.finalImage = Image(uiImage: preprocessedImage)
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.engineMode = .tesseractCubeCombined
            //.tesseractOnly = fastest but least accurate method
            //.cubeOnly = slower but more accurate since it employs more AI
            //.tesseractCubeCombined = runs both .tesseractOnly & .cubeOnly; slowest but most accurate
            tesseract.pageSegmentationMode = .auto //lets it know how the text is divided- paragraph breaks
            tesseract.image = preprocessedImage
            tesseract.recognize()
            //hocr gets html/text that orders text in columns from left to right
            let hocr = tesseract.recognizedHOCR(forPageNumber: 1)
            //find all WORDS and add to the 'words' array- filter out excess html stuff
            print(hocr!)
            let words = matches(for: "([^<>]+(?=</strong))", in: hocr!)
            self.ocrProperties.dataArray = words
            //TODO: CREATE NEW ROW IN ARRAY BASED ON COLUMNS

            //Create a printable string from the array- not needed for processing, but nice to see on the screen for testing
            var all_words = ""
            for word in words {
                all_words += word
                all_words += " "
            }
            ocrProperties.text = (all_words != "" ? all_words : "No text recognized.")
        }
        //self.ocrProperties.page = "Results"
        self.ocrProperties.page = "Graph"
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
    
    func preprocessedImage() -> UIImage? {
        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
        // GPU Threshold Filter “determines the local luminance around a pixel, then turns the pixel black if it is below that local luminance, and white if above. This can be useful for picking out text under varying lighting conditions.”
        stillImageFilter.blurRadiusInPixels = 15.0 //defaults to 4.0
        let filteredImage = stillImageFilter.image(byFilteringImage: self)
        return filteredImage
    }
    
}
