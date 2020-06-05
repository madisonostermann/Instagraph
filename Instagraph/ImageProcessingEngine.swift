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
    
    /*func performImageRecognition(image: UIImage) {
        let scaledImage = image.scaledImage(1000) ?? image
        let preprocessedImage = scaledImage.preprocessedImage() ?? scaledImage
        ocrProperties.finalImage = Image(uiImage: preprocessedImage)
        //finalImage = Image(uiImage: preprocessedImage)
        if let tesseract = G8Tesseract(language: "eng") {
          tesseract.engineMode = .tesseractCubeCombined
            //.tesseractOnly = fastest but least accurate method
            //.cubeOnly = slower but more accurate since it employs more AI
            //.tesseractCubeCombined = runs both .tesseractOnly & .cubeOnly; slowest but most accurate
          tesseract.pageSegmentationMode = .auto //lets it know how the text is divided- paragraph breaks
          tesseract.image = preprocessedImage
          tesseract.recognize()
            //text = (tesseract.recognizedText != nil ? tesseract.recognizedText : "No text recognized.")!
            ocrProperties.text = (tesseract.recognizedText != nil ? tesseract.recognizedText : "No text recognized.")!
            //print("Recognized text: ", text)
            print("Recognized text: ", ocrProperties.text)
          //textView.text = tesseract.recognizedText
        }
    }*/
}

//To scale image for Tesseract
//UIImage Extension allows access to any of its methods directly through a UIImage object
/*extension UIImage {
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

    //TODO: really messed up a screenshot in dark mode
  func preprocessedImage() -> UIImage? {
    let stillImageFilter = GPUImageAdaptiveThresholdFilter()
    // GPU Threshold Filter “determines the local luminance around a pixel, then turns the pixel black if it is below that local luminance, and white if above. This can be useful for picking out text under varying lighting conditions.”
    stillImageFilter.blurRadiusInPixels = 15.0 //defaults to 4.0
    let filteredImage = stillImageFilter.image(byFilteringImage: self)
    return filteredImage
  }
    
}*/
