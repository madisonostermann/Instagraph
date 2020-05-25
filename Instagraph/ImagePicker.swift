//
//  ImagePicker.swift
//  Instagraph
//
//  Created by Madison Gipson on 5/25/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import TesseractOCR
import GPUImage
import MobileCoreServices

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var isShown: Bool
    @Binding var image: Image?
    @Binding var finalImage: Image?
    @Binding var text: String
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    init(isShown: Binding<Bool>, image: Binding<Image?>, finalImage: Binding<Image?>, text: Binding<String>) {
        _isShown = isShown
        _image = image
        _finalImage = finalImage
        _text = text
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.activityIndictor.startAnimating()
        let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        image = Image(uiImage: uiImage)
        isShown = false
        picker.dismiss(animated: true, completion: nil)
        self.activityIndictor.stopAnimating()
        self.performImageRecognition(image: uiImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
        self.activityIndictor.stopAnimating()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func performImageRecognition(image: UIImage) {
        self.activityIndictor.startAnimating()
        let scaledImage = image.scaledImage(1000) ?? image
        let preprocessedImage = scaledImage.preprocessedImage() ?? scaledImage
        finalImage = Image(uiImage: preprocessedImage)
        if let tesseract = G8Tesseract(language: "eng") {
          tesseract.engineMode = .tesseractCubeCombined
            //.tesseractOnly = fastest but least accurate method
            //.cubeOnly = slower but more accurate since it employs more AI
            //.tesseractCubeCombined = runs both .tesseractOnly & .cubeOnly; slowest but most accurate
          tesseract.pageSegmentationMode = .auto //lets it know how the text is divided- paragraph breaks
          tesseract.image = preprocessedImage
          tesseract.recognize()
            text = (tesseract.recognizedText != nil ? tesseract.recognizedText : "No text recognized.")!
            print("Recognized text: ", text)
          //textView.text = tesseract.recognizedText
        }
        self.activityIndictor.stopAnimating()
    }
    
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var isShown: Bool
    var source: String
    @Binding var image: Image?
    @Binding var finalImage: Image?
    @Binding var text: String
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(isShown: $isShown, image: $image, finalImage: $finalImage, text: $text)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        self.activityIndictor.startAnimating()
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        //picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeImage as String] //only still images
        if source == "Photo" {
            picker.sourceType = .photoLibrary
        } else if source == "Camera" {
            picker.sourceType = .camera
        //} else if source == "Document" {
            //picker.sourceType = //document finder
        }
        self.activityIndictor.stopAnimating()
        return picker
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

    //TODO: really messed up a screenshot in dark mode
  func preprocessedImage() -> UIImage? {
    let stillImageFilter = GPUImageAdaptiveThresholdFilter()
    // GPU Threshold Filter “determines the local luminance around a pixel, then turns the pixel black if it is below that local luminance, and white if above. This can be useful for picking out text under varying lighting conditions.”
    stillImageFilter.blurRadiusInPixels = 15.0 //defaults to 4.0
    let filteredImage = stillImageFilter.image(byFilteringImage: self)
    return filteredImage
  }
    
}
