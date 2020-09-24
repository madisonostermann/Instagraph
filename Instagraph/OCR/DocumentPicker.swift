//
//  DocumentPicker.swift
//  Instagraph
//
//  Created by Madison Gipson on 5/25/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import MobileCoreServices

/*class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    @ObservedObject var ocrProperties: OCRProperties
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)

    init(ocrProperties: OCRProperties) {
        self.ocrProperties = ocrProperties
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        self.activityIndictor.startAnimating()
        //ocrProperties.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        self.activityIndictor.stopAnimating()
        OCRSortingEngine(ocrProperties: ocrProperties).performImageRecognition()
    }


    public func documentMenu(_ documentMenu:UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        //present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        self.activityIndictor.stopAnimating()
        picker.dismiss(animated: true, completion: nil)
    }
}*/

/*struct DocumentPicker: UIViewControllerRepresentable {
    func makeCoordinator() -> DocumentPicker.Coordinator {
        return DocumentPicker.Coordinator(ocrProperties: self.ocrProperties, docPicker: self)
    }
    
    @ObservedObject var ocrProperties: OCRProperties
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    func updateUIViewController(_ uiViewController: DocumentPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<DocumentPicker>) { }

    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        self.activityIndictor.startAnimating()
        let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypePNG), String(kUTTypeJPEG)], in: .open) //.import
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator //as UIDocumentPickerDelegate //self
        //picker.modalPresentationStyle = .formSheet
        self.activityIndictor.stopAnimating()
        return picker //self.present(picker, animated: true, completion: nil)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @ObservedObject var ocrProperties: OCRProperties
        var docPicker: DocumentPicker
        
        init(ocrProperties: OCRProperties, docPicker: DocumentPicker) {
            self.ocrProperties = ocrProperties
            self.docPicker = docPicker
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print(urls)
        }
        
        /*func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("view was cancelled")
            DocumentPicker.Coordinator.dismiss(animated: true, completion: nil)
        }*/
    }
}*/

/*class Document: UIDocument {
    var data: Data?
    override func contents(forType typeName: String) throws -> Any {
        guard let data = data else { return Data() }
        return try NSKeyedArchiver.archivedData(withRootObject:data,
            requiringSecureCoding: true)
    }
    override func load(fromContents contents: Any, ofType typeName:
        String?) throws {
        guard let data = contents as? Data else { return }
        self.data = data
    }
}

protocol DocumentDelegate: class {
    func didPickDocuments(documents: [Document]?)
}

open class DocumentPicker: NSObject {
    private var pickerController: UIDocumentPickerViewController?
    private weak var presentationController: UIViewController?
    private weak var delegate: DocumentDelegate?
    private var folderURL: URL?
    private var sourceType: SourceType!
    private var documents = [Document]()
    init(presentationController: UIViewController,
        delegate:   DocumentDelegate) {
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
    }
}*/
