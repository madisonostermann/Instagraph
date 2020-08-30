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

    @ObservedObject var ocrProperties: OCRProperties
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)

    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.activityIndictor.startAnimating()
        self.ocrProperties.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        self.activityIndictor.stopAnimating()
        self.ocrProperties.image = ClearLinesBridge().detectLine(in: self.ocrProperties.image) // 3. Image Processing (correct perspective & clean up image)
        Crop(ocrProperties: ocrProperties).setup() // 4. Crop (manually)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.activityIndictor.stopAnimating()
        picker.dismiss(animated: true, completion: nil)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @ObservedObject var ocrProperties: OCRProperties
    
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(ocrProperties: self.ocrProperties)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        self.activityIndictor.startAnimating()
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = [kUTTypeImage as String] //only still images
        picker.sourceType = .photoLibrary
        self.activityIndictor.stopAnimating()
        return picker
    }
    
}
