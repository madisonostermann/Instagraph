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
    var words = [String]()
    
    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func performImageRecognition() {
        for image in self.ocrProperties.croppedImages! {
            if let tesseract = G8Tesseract(language: "eng") {
                tesseract.engineMode = .tesseractCubeCombined
                tesseract.pageSegmentationMode = .auto //lets it know how the text is divided- paragraph breaks
                tesseract.image = image
                //hOCR gets html/text
                let hOCR = tesseract.recognizedHOCR(forPageNumber: 1)
//                print(hOCR)
                let word = matches(for: "(?<='eng'>)[a-zA-Z0-9!@#$&()\\-`.+,/\"]*|([^<>]+(?=</))", in: hOCR!)
                for i in word.indices {
                    if word[i] != "" && !word[i].trimmingCharacters(in: .whitespaces).isEmpty && !word[i].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        words.append(word[i])
                    }
                }
            }
        }
        let seq = zip(self.ocrProperties.textLocations!, words) 
        for (loc, word) in seq {
            print(word)
            print(loc)
        }
//        self.ocrProperties.page = "Graph"
    }
    
    //used in "sanitize" method for parsing the HTML for words & bbox info
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
